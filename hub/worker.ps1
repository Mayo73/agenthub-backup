# Worker: arbeitet die Tickets in tickets\todo nacheinander mit dem lokalen Modell ab.
#
#   Normalbetrieb:   start-hub.cmd (startet Worker und Dashboard unsichtbar)
#   Zum Zuschauen:   powershell -NoProfile -ExecutionPolicy Bypass -File hub\worker.ps1
#   Nur ein Ticket:  ... -File hub\worker.ps1 -Once
#
# Ablauf pro Ticket:
#   1. Branch agent/<id> im Worktree workspaces\<projekt> anlegen (deine Arbeitskopie bleibt unberührt)
#   2. claude-local im eingeschränkten Modus arbeiten lassen (nur Lesen/Schreiben/Suchen, keine Shell)
#   3. verify.cmd ausführen; bei Fehlern die Ausgabe an den Agent zurückgeben (bis max_attempts)
#   4. Ergebnis committen, Bericht schreiben, Ticket nach review bzw. failed verschieben
param([switch]$Once)

. (Join-Path $PSScriptRoot 'common.ps1')
$ErrorActionPreference = 'Continue'   # git und cmd schreiben Hinweise auf stderr

if (-not (Enter-SingleInstance 'Worker')) { Write-Host 'Der Worker läuft bereits.'; exit 0 }

# Variablen einer umgebenden Claude-Sitzung entfernen: Maßgeblich ist nur claude-local.cmd.
# NoDefaultCurrentDirectoryInExePath setzt die Claude-App; damit fände cmd "verify.cmd" im Projektordner nicht.
Get-ChildItem Env: | Where-Object { $_.Name -match '^(ANTHROPIC|CLAUDE|NoDefaultCurrentDirectoryInExePath$)' } |
    ForEach-Object { Remove-Item -LiteralPath "Env:$($_.Name)" -ErrorAction SilentlyContinue }

foreach ($dir in @('state', 'runs', 'workspaces') + @($script:Columns | ForEach-Object { "tickets\$_" })) {
    New-Item -ItemType Directory -Force -Path (Get-HubPath $dir) | Out-Null
}
Write-Text (Get-HubPath 'state\worker.pid') "$PID"

# Ausgaben von git & Co. als UTF-8 lesen, sonst werden Umlaute zur DOS-Codepage verbogen.
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch { }

$script:Git = Resolve-Git
$script:Cfg = Get-HubConfig
$script:WorkerState = [ordered]@{
    pid = $PID; state = 'starting'; ticket = $null; title = $null; project = $null
    attempt = 0; maxAttempts = 0; phase = $null; phaseSince = $null; ticketSince = $null
    model = $null; message = $null; heartbeat = $null
}

$script:StatusCheck = [datetime]::MinValue

function Set-WorkerState([hashtable]$Changes = @{}) {
    foreach ($key in $Changes.Keys) { $script:WorkerState[$key] = $Changes[$key] }
    $script:WorkerState.heartbeat = Get-Now
    Write-Json (Get-HubPath 'state\worker.json') $script:WorkerState
    # Etwa jede Minute lastenhefte/STATUS.md für ChatGPT auffrischen; Fehler dürfen den Worker nie stoppen.
    if (((Get-Date) - $script:StatusCheck).TotalSeconds -ge 60) {
        $script:StatusCheck = Get-Date
        try { Update-StatusFile } catch { Add-HubLog "STATUS.md konnte nicht geschrieben werden: $($_.Exception.Message)" }
        try { Update-Benachrichtigungen ($script:WorkerState.state -ne 'waiting') } catch { Add-HubLog "Benachrichtigung fehlgeschlagen: $($_.Exception.Message)" }
    }
}

function Set-Phase([string]$Phase) { Set-WorkerState @{ phase = $Phase; phaseSince = (Get-Now) } }

# Startet cmd.exe unsichtbar, meldet währenddessen Herzschläge ans Dashboard
# und beendet den ganzen Prozessbaum, wenn das Zeitlimit erreicht ist.
function Invoke-Hidden([string]$CommandLine, [string]$WorkDir, [double]$TimeoutMinutes) {
    $proc = Start-Process -FilePath $env:ComSpec -ArgumentList "/d /s /c `"$CommandLine`"" `
        -WorkingDirectory $WorkDir -WindowStyle Hidden -PassThru
    $null = $proc.Handle   # sonst ist ExitCode später leer
    $deadline = (Get-Date).AddMinutes($TimeoutMinutes)
    while (-not $proc.WaitForExit(10000)) {
        Set-WorkerState
        if ((Get-Date) -gt $deadline) {
            & taskkill.exe /PID $proc.Id /T /F 2>&1 | Out-Null
            return [pscustomobject]@{ ExitCode = -1; TimedOut = $true }
        }
    }
    $proc.WaitForExit()
    [pscustomobject]@{ ExitCode = $proc.ExitCode; TimedOut = $false }
}

function New-FirstPrompt($Ticket) {
@"
Du bist ein Programmier-Agent und arbeitest allein an genau einem Ticket im Projekt im aktuellen Ordner.

So gehst du vor:
1. Lies zuerst CLAUDE.md (Projektregeln, Aufbau, Technik) und die im Ticket genannten Dateien.
2. Setze das Ticket vollständig um. Ändere nur, was dafür nötig ist.
3. Schreibe die Tests, die das Ticket verlangt.
4. Du kannst keine Befehle ausführen. Nach deiner Antwort prüft ein Skript automatisch das ganze Projekt (zum Beispiel Syntaxfehler und Tests). Schlägt das fehl, bekommst du die Fehlermeldungen und darfst nachbessern.
5. Antworte zum Schluss mit 2 bis 4 Sätzen: Was hast du geändert und warum?

=== TICKET $($Ticket.Id): $($Ticket.Title) ===

$($Ticket.Body)
"@
}

function New-RetryPrompt([int]$Attempt, [int]$MaxAttempts, [string]$Feedback) {
@"
Die automatische Prüfung ist FEHLGESCHLAGEN (Versuch $Attempt von $MaxAttempts). Ausgabe der Prüfung:

``````
$Feedback
``````

Finde die Ursache und behebe sie. Ändere nur, was dafür nötig ist, und schwäche keine Tests ab.
Antworte zum Schluss wieder mit 2 bis 4 Sätzen.
"@
}

# Godot-Ausgabe ohne Farbcodes und Fortschrittszeilen.
function Get-CleanOutput([string]$Raw) {
    if (-not $Raw) { return '' }
    $esc = [char]27
    $lines = ($Raw -replace "$esc\[[0-9;?]*[A-Za-z]", '') -split '\r?\n' | Where-Object {
        $_.Trim() -ne '' -and $_ -notmatch '^\[\s*\d+% \]' -and $_ -notmatch '^\[ DONE \]'
    }
    return (@($lines) -join "`r`n")
}

# Für den Agent: zuerst alle Fehlerzeilen, dann das Ende der Ausgabe.
function Get-Feedback([string]$Clean) {
    $lines = @($Clean -split '\r?\n')
    $errors = @($lines | Where-Object { $_ -match 'SCRIPT ERROR|Parse Error|ERROR|FEHLER|at: ' } | Select-Object -Unique -First 40)
    $tail = @($lines | Select-Object -Last 25)
    if ($errors.Count -eq 0) { return ($tail -join "`n") }
    return "Fehlermeldungen:`n" + ($errors -join "`n") + "`n`nEnde der Ausgabe:`n" + ($tail -join "`n")
}

function Invoke-Agent([string]$Workspace, [string]$RunDir, [int]$Attempt, [string]$Prompt, [string]$ResumeId, [string]$Model, [double]$TimeoutMinutes) {
    $promptFile = Join-Path $RunDir "prompt-$Attempt.txt"
    $outFile    = Join-Path $RunDir "agent-$Attempt.json"
    $errFile    = Join-Path $RunDir "agent-$Attempt.err.txt"
    Write-Text $promptFile $Prompt
    # --restricted: keine Shell-Tools, Dateizugriff nur im Arbeitsordner, Git-/Einstellungsdateien geschützt.
    # --strict-mcp-config: keine MCP-Server (z. B. Higgsfield), damit lokale Agents keine Credits ausgeben.
    $flags = '-p --output-format json --restricted --strict-mcp-config --tools Read,Edit,Write,Glob,Grep --permission-mode acceptEdits --permission-prompts none'
    if ($ResumeId) { $flags += " --resume $ResumeId" }
    $env:CLAUDE_LOCAL_MODEL = $Model
    $started = Get-Date
    $run = Invoke-Hidden "`"$($script:Cfg.claudeLocal)`" $flags < `"$promptFile`" > `"$outFile`" 2> `"$errFile`"" $Workspace $TimeoutMinutes
    $json = Read-Json $outFile
    $result = [pscustomobject]@{
        ExitCode = $run.ExitCode; TimedOut = $run.TimedOut
        Seconds = [int]((Get-Date) - $started).TotalSeconds
        Summary = $null; SessionId = $null; Turns = $null; IsError = $true
    }
    if ($json) {
        $result.Summary = $json.result
        $result.SessionId = $json.session_id
        $result.Turns = $json.num_turns
        $result.IsError = [bool]$json.is_error
    }
    return $result
}

function Invoke-Verify($Ticket, $Project, [string]$Workspace, [string]$RunDir, [int]$Attempt, [string]$BaseCommit, [int]$MinTests = -1) {
    # Prüfwerkzeuge auf den Stand von main zurücksetzen, damit der Agent sie nicht "grün schreiben" kann.
    $tampered = @()
    foreach ($file in @($Project.protected)) {
        if (-not $file) { continue }
        if ((Invoke-Git $Workspace @('diff', '--quiet', $BaseCommit, '--', $file)).Code -ne 0) {
            $tampered += $file
            Invoke-Git $Workspace @('checkout', $BaseCommit, '--', $file) | Out-Null
        }
    }
    $verify = $Project.verify
    if ($Ticket.Verify -and $Ticket.Verify -ne 'default') { $verify = $Ticket.Verify }
    $log = Join-Path $RunDir "verify-$Attempt.log"
    $started = Get-Date
    $run = Invoke-Hidden "$verify > `"$log`" 2>&1" $Workspace $script:Cfg.verifyTimeoutMinutes
    $clean = Get-CleanOutput (Read-Text $log)
    if ($run.TimedOut) { $clean += "`r`n== Prüfung nach $($script:Cfg.verifyTimeoutMinutes) Minuten abgebrochen ==" }
    $passed = (-not $run.TimedOut -and $run.ExitCode -eq 0)
    # Gegen grün geschriebene Prüfungen: genau eine Ergebniszeile und nicht weniger Tests als vor dem Agent.
    $tests = Get-TestCount $Project $clean
    if ($passed -and $tests -eq -1) {
        $passed = $false
        $clean += "`r`n== FEHLER: Die Prüfung muss genau eine Ergebniszeile ausgeben. Gib im Code keine eigene Ergebniszeile aus. =="
    } elseif ($passed -and $null -ne $tests -and $MinTests -ge 0 -and $tests -lt $MinTests) {
        $passed = $false
        $clean += "`r`n== FEHLER: Vor deinen Änderungen liefen $MinTests Tests, jetzt nur $tests. Lösche, deaktiviere oder benenne keine Tests um. =="
    }
    Write-Text $log $clean
    [pscustomobject]@{
        Passed   = $passed
        Seconds  = [int]((Get-Date) - $started).TotalSeconds
        Feedback = Get-Feedback $clean
        Tampered = $tampered
        Tests    = $tests
    }
}

function Write-Report($Status, [string]$RunDir) {
    $lines = New-Object System.Collections.ArrayList
    $count = $Status.attempts.Count
    [void]$lines.Add("# $($Status.id): $($Status.title)")
    [void]$lines.Add('')
    if ($Status.state -eq 'passed') {
        [void]$lines.Add("**Ergebnis:** Prüfung bestanden nach $count Versuch(en). Branch ``$($Status.branch)``, Commit ``$($Status.commit)``.")
    } else {
        [void]$lines.Add("**Ergebnis:** Nach $count Versuch(en) nicht bestanden. Änderungen siehe diff.patch.")
    }
    $total = ([datetime]::Parse($Status.finished) - [datetime]::Parse($Status.started)).TotalSeconds
    [void]$lines.Add('')
    $facts = "Modell: $($Status.model) · Gesamtdauer: $(Format-Duration $total)"
    if ($null -ne $Status.testsBefore -and $null -ne $Status.testsAfter -and $Status.testsBefore -ge 0 -and $Status.testsAfter -ge 0) {
        $facts += " · Tests: $($Status.testsBefore) vorher, $($Status.testsAfter) nachher"
    }
    [void]$lines.Add($facts)
    if ($Status.stackedOn.Count -gt 0) {
        [void]$lines.Add('')
        [void]$lines.Add("**Gestapelt:** baut auf noch nicht gemergten Tickets auf ($($Status.stackedOn -join ', ')). Diese zuerst reviewen und mergen. diff.patch zeigt nur die eigenen Änderungen.")
    }
    if ($Status.warnings.Count -gt 0) {
        [void]$lines.Add(''); [void]$lines.Add('## Hinweise für den Review'); [void]$lines.Add('')
        foreach ($w in $Status.warnings) { [void]$lines.Add("- $w") }
    }
    [void]$lines.Add(''); [void]$lines.Add('## Zusammenfassung des Agents'); [void]$lines.Add('')
    if ($Status.summary) { [void]$lines.Add($Status.summary) } else { [void]$lines.Add('(keine)') }
    [void]$lines.Add(''); [void]$lines.Add('## Geänderte Dateien'); [void]$lines.Add('')
    if ($Status.diffStat) { [void]$lines.Add('```'); [void]$lines.Add($Status.diffStat); [void]$lines.Add('```') } else { [void]$lines.Add('(keine)') }
    [void]$lines.Add(''); [void]$lines.Add('## Versuche'); [void]$lines.Add('')
    [void]$lines.Add('| Versuch | Agent | Züge | Dateien | Prüfung |')
    [void]$lines.Add('|---|---|---|---|---|')
    foreach ($a in $Status.attempts) {
        $check = if ($a.note) { $a.note } elseif ($a.verifyPassed) { "bestanden ($($a.verifySeconds) s)" } else { "fehlgeschlagen ($($a.verifySeconds) s)" }
        [void]$lines.Add("| $($a.n) | $(Format-Duration $a.agentSeconds) | $($a.turns) | $($a.changedFiles) | $check |")
    }
    Write-Text (Join-Path $RunDir 'report.md') (($lines -join "`r`n") + "`r`n")
}

function Invoke-Ticket($Ticket) {
    $cfg = $script:Cfg
    $id = $Ticket.Id
    $project = $null
    if ($Ticket.Project) { $project = $cfg.projects.($Ticket.Project) }
    if (-not $project) {
        Move-Ticket $Ticket 'failed' | Out-Null
        Write-Json (Join-Path (Get-RunDir $id) 'status.json') ([ordered]@{
            id = $id; title = $Ticket.Title; state = 'failed'; finished = (Get-Now); attempts = @()
            message = "Unbekanntes Projekt '$($Ticket.Project)'. Erlaubt sind die Projekte aus config.json."
        })
        Add-HubLog "${id}: unbekanntes Projekt '$($Ticket.Project)' -> Fehlgeschlagen"
        return
    }

    $Ticket = Move-Ticket $Ticket 'doing'
    $runDir = Get-RunDir $id
    if (Test-Path -LiteralPath $runDir) {
        # Früherer Lauf (z. B. vor "Erneut versuchen") bleibt zum Nachlesen erhalten.
        Rename-Item -LiteralPath $runDir -NewName ("$id.alt-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    }
    New-Item -ItemType Directory -Force -Path $runDir | Out-Null

    $model = $cfg.defaultModel
    if ($Ticket.Model) { $model = $Ticket.Model }
    $maxAttempts = [int]$cfg.maxAttempts
    if ($Ticket.MaxAttempts -gt 0) { $maxAttempts = $Ticket.MaxAttempts }
    # Zeitlimit pro Agent-Lauf: Standard aus config.json, langsamere Modelle per "timeout_minutes:" im Ticket.
    $timeout = [double]$cfg.agentTimeoutMinutes
    if ($Ticket.TimeoutMinutes -gt 0) { $timeout = $Ticket.TimeoutMinutes }
    $branch = "agent/$id"
    $statusFile = Join-Path $runDir 'status.json'
    $status = [ordered]@{
        id = $id; title = $Ticket.Title; project = $Ticket.Project; model = $model; branch = $branch
        state = 'running'; started = (Get-Now); finished = $null
        attempts = (New-Object System.Collections.ArrayList)
        warnings = (New-Object System.Collections.ArrayList)
        stackedOn = (New-Object System.Collections.ArrayList)
        commit = $null; diffStat = $null; changedFiles = @(); summary = $null; message = $null
        testsBefore = $null; testsAfter = $null
    }
    Write-Json $statusFile $status
    Add-HubLog "${id} gestartet: $($Ticket.Title) (Modell $model)"
    Set-WorkerState @{
        state = 'working'; ticket = $id; title = $Ticket.Title; project = $Ticket.Project
        attempt = 0; maxAttempts = $maxAttempts; model = $model; ticketSince = (Get-Now); message = $null
    }

    # Ein Git-Worktree pro Projekt, ein Branch pro Ticket.
    Set-Phase 'Arbeitsbereich vorbereiten'
    $ws = Get-HubPath "workspaces\$($Ticket.Project)"
    if (-not (Test-Path -LiteralPath (Join-Path $ws '.git'))) {
        Invoke-Git $project.path @('worktree', 'prune') | Out-Null
        $r = Invoke-Git $project.path @('worktree', 'add', '--detach', $ws, $project.baseBranch)
        if ($r.Code -ne 0) { throw "Worktree konnte nicht angelegt werden: $($r.Output)" }
    }
    $r = Invoke-Git $ws @('checkout', '-q', '-f', '-B', $branch, $project.baseBranch)
    if ($r.Code -ne 0) { throw "Branch $branch konnte nicht angelegt werden: $($r.Output)" }
    Invoke-Git $ws @('clean', '-fdq') | Out-Null

    # Gestapeltes Ticket: Vorgänger, die noch auf den Review warten, in den Branch holen.
    foreach ($dep in (Merge-StackedBases $ws $Ticket)) { [void]$status.stackedOn.Add($dep) }
    # Basis für Diff und Bericht: nach den Vorgängern, damit nur die eigenen Änderungen zählen.
    $baseCommit = (Invoke-Git $ws @('rev-parse', 'HEAD')).Output
    if ($status.stackedOn.Count -gt 0) {
        Add-HubLog "${id} baut auf noch nicht gemergten Tickets auf: $($status.stackedOn -join ', ')"
    }

    # Ausgangslage (verify-0.log): Ist der Stand vor dem Agent grün, und wie viele Tests laufen?
    Set-Phase 'Ausgangslage prüfen'
    $before = Invoke-Verify $Ticket $project $ws $runDir 0 $baseCommit
    $minTests = -1
    $status.testsBefore = $before.Tests
    if (-not $before.Passed) {
        [void]$status.warnings.Add('Die Prüfung war schon vor dem Agent rot (siehe verify-0.log). Fehlschläge liegen dann nicht unbedingt am Agent.')
        Add-HubLog "${id}: Prüfung schon vor dem Agent rot"
    } elseif ($null -ne $before.Tests) {
        $minTests = $before.Tests
    }
    Write-Json $statusFile $status

    $passed = $false
    $resumeId = $null
    $feedback = $null
    for ($n = 1; $n -le $maxAttempts; $n++) {
        Set-WorkerState @{ attempt = $n }
        Set-Phase 'Agent arbeitet'
        if ($n -eq 1) { $prompt = New-FirstPrompt $Ticket }
        elseif ($resumeId) { $prompt = $feedback }   # gleiche Sitzung: Ollama kann den Prompt-Cache nutzen
        else { $prompt = (New-FirstPrompt $Ticket) + "`r`n`r`n" + $feedback }

        $agent = Invoke-Agent $ws $runDir $n $prompt $resumeId $model $timeout
        if ($agent.SessionId) { $resumeId = $agent.SessionId }
        $attempt = [ordered]@{
            n = $n; agentSeconds = $agent.Seconds; turns = $agent.Turns
            agentError = ($agent.IsError -or $agent.ExitCode -ne 0); timedOut = $agent.TimedOut
            summary = $agent.Summary; changedFiles = 0; verifyPassed = $false; verifySeconds = $null; note = $null
        }
        $changes = @((Invoke-Git $ws @('status', '--porcelain')).Output -split "`n" | Where-Object { $_.Trim() })
        $attempt.changedFiles = $changes.Count
        if ($changes.Count -eq 0) {
            $attempt.note = 'keine Datei geändert'
            if ($agent.TimedOut) { $attempt.note = 'Zeitlimit erreicht, keine Datei geändert' }
            elseif ($attempt.agentError) { $attempt.note = 'Agent-Fehler, keine Datei geändert' }
            $feedback = 'Du hast noch keine Datei geändert. Setze das Ticket jetzt um und benutze dafür die Werkzeuge Edit oder Write.'
            [void]$status.attempts.Add($attempt)
            Write-Json $statusFile $status
            Add-HubLog "${id} Versuch ${n}: $($attempt.note)"
            continue
        }

        Set-Phase 'Prüfung läuft'
        $verify = Invoke-Verify $Ticket $project $ws $runDir $n $baseCommit $minTests
        $attempt.verifyPassed = $verify.Passed
        $status.testsAfter = $verify.Tests
        $attempt.verifySeconds = $verify.Seconds
        foreach ($f in $verify.Tampered) {
            [void]$status.warnings.Add("Versuch ${n}: Der Agent hat die geschützte Datei $f geändert (vor der Prüfung zurückgesetzt).")
        }
        [void]$status.attempts.Add($attempt)
        Write-Json $statusFile $status
        if ($verify.Passed) {
            Add-HubLog "${id} Versuch ${n}: Prüfung bestanden"
            $passed = $true
            break
        }
        Add-HubLog "${id} Versuch ${n}: Prüfung fehlgeschlagen"
        $feedback = New-RetryPrompt $n $maxAttempts $verify.Feedback
    }

    Set-Phase 'Ergebnis sichern'
    Invoke-Git $ws @('add', '-A') | Out-Null
    $status.changedFiles = @((Invoke-Git $ws @('diff', '--cached', '--name-status', $baseCommit)).Output -split "`n" | Where-Object { $_.Trim() })
    $status.diffStat = (Invoke-Git $ws @('diff', '--cached', '--stat', $baseCommit)).Output
    # git schreibt den Diff selbst: so bleiben Umlaute byte-genau erhalten.
    Invoke-Git $ws @('diff', '--cached', "--output=$(Join-Path $runDir 'diff.patch')", $baseCommit) | Out-Null
    # Nur warnen, wenn in Testdateien Zeilen wegfallen. Angehängte Tests sind erwünscht.
    foreach ($line in ((Invoke-Git $ws @('diff', '--cached', '--numstat', $baseCommit)).Output -split "`n")) {
        if ($line -match '^(\d+)\s+(\d+)\s+(tests/\S+)$' -and [int]$Matches[2] -gt 0) {
            [void]$status.warnings.Add("In $($Matches[3]) wurden $($Matches[2]) bestehende Zeilen geändert oder entfernt. Prüfen, ob Tests abgeschwächt wurden.")
        }
    }
    $last = $status.attempts | Select-Object -Last 1
    if ($last) { $status.summary = $last.summary }

    if ($passed) {
        $msgFile = Join-Path $runDir 'commit-msg.txt'
        Write-Text $msgFile "${id}: $($Ticket.Title)`n`nErstellt vom lokalen Agent (Modell $model, Versuch $n von $maxAttempts).`n"
        $r = Invoke-Git $ws @('-c', 'user.name=Lokaler Agent', '-c', 'user.email=agent@localhost', 'commit', '-q', '-F', $msgFile)
        if ($r.Code -ne 0) { throw "Commit fehlgeschlagen: $($r.Output)" }
        $status.commit = (Invoke-Git $ws @('rev-parse', '--short', 'HEAD')).Output
        $status.state = 'passed'
        foreach ($w in (Get-ConflictWarnings $ws $branch $project.baseBranch)) { [void]$status.warnings.Add($w) }
    } else {
        $status.state = 'failed'
    }
    # Worktree freigeben: Bei Erfolg bleibt der Branch für den Review erhalten.
    Invoke-Git $ws @('checkout', '-q', '-f', '--detach', $baseCommit) | Out-Null
    Invoke-Git $ws @('clean', '-fdq') | Out-Null
    if (-not $passed) { Invoke-Git $ws @('branch', '-q', '-D', $branch) | Out-Null }

    $status.finished = Get-Now
    Write-Json $statusFile $status
    Write-Report $status $runDir
    if ($passed) {
        Move-Ticket $Ticket 'review' | Out-Null
        Add-HubLog "${id} fertig -> Zur Prüfung (Branch $branch)"
    } else {
        Move-Ticket $Ticket 'failed' | Out-Null
        Add-HubLog "${id} nach $maxAttempts Versuchen fehlgeschlagen"
    }
}

# --- Hauptschleife ------------------------------------------------------------

foreach ($ticket in @(Get-Tickets 'doing')) {
    Add-HubLog "$($ticket.Id) war beim letzten Beenden in Arbeit -> zurück nach Offen"
    Move-Ticket $ticket 'todo' | Out-Null
}
Add-HubLog "Worker gestartet (PID $PID)"

while ($true) {
    $script:Cfg = Get-HubConfig   # Änderungen an config.json gelten ohne Neustart
    $env:GODOT_BIN = Resolve-GodotBin $script:Cfg
    $idle = @{
        state = 'idle'; ticket = $null; title = $null; project = $null; attempt = 0; maxAttempts = 0
        phase = $null; phaseSince = $null; ticketSince = $null; message = $null
    }
    if (Test-Path -LiteralPath (Get-HubPath 'state\paused')) {
        $idle.state = 'paused'
        Set-WorkerState $idle
        Start-Sleep -Seconds 10
        continue
    }
    if (-not (Test-Ollama $script:Cfg)) {
        $idle.state = 'waiting'
        $idle.message = 'Ollama ist nicht erreichbar.'
        Set-WorkerState $idle
        Start-Sleep -Seconds 30
        continue
    }
    # Tickets mit "after:" starten, sobald alle Vorgänger erledigt sind oder die Prüfung bestanden haben.
    $next = Get-NextTicket
    if (-not $next) {
        Set-WorkerState $idle
        if ($Once) { break }
        Start-Sleep -Seconds ([int]$script:Cfg.idleSeconds)
        continue
    }
    try {
        Invoke-Ticket $next
    } catch {
        $err = "$($_.Exception.Message)"
        Add-HubLog "$($next.Id): Fehler im Worker: $err"
        $stuck = Find-Ticket $next.Id
        if ($stuck -and $stuck.Column -eq 'doing') { Move-Ticket $stuck 'failed' | Out-Null }
        $statusFile = Join-Path (Get-RunDir $next.Id) 'status.json'
        $st = Read-Json $statusFile
        if ($st) {
            $st.state = 'failed'
            $st | Add-Member -NotePropertyName message -NotePropertyValue "Fehler im Worker: $err" -Force
            Write-Json $statusFile $st
        }
        Set-WorkerState @{ message = "Fehler bei $($next.Id): $err" }
        Start-Sleep -Seconds 10
    }
    if ($Once) { break }
}
