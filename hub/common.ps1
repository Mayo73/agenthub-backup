# Gemeinsame Funktionen für den Worker (worker.ps1) und den Dashboard-Server (server.ps1).

$script:HubRoot   = Split-Path -Parent $PSScriptRoot
$script:Columns   = @('todo', 'doing', 'review', 'failed', 'done')
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$script:IdPattern = '^T-\d{3,6}$'

function Get-HubPath([string]$Relative) { Join-Path $script:HubRoot $Relative }

function Get-Now { (Get-Date).ToString('o') }

function Read-Text([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    for ($i = 0; $i -lt 5; $i++) {
        try { return [IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8) } catch { Start-Sleep -Milliseconds 100 }
    }
    return $null
}

function Write-Text([string]$Path, [string]$Text) {
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [IO.File]::WriteAllText($Path, $Text, $script:Utf8NoBom)
}

function Read-Json([string]$Path) {
    $text = Read-Text $Path
    if ([string]::IsNullOrWhiteSpace($text)) { return $null }
    try { return ($text | ConvertFrom-Json) } catch { return $null }
}

$script:JsonCache = @{}

## Wie Read-Json, liest die Datei aber nur neu, wenn sie sich geändert hat (für die vielen
## status.json im Dashboard). Das Objekt wird geteilt: nur lesen, nie verändern.
function Read-JsonCached([string]$Path) {
    $item = Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue
    if (-not $item) { return $null }
    $hit = $script:JsonCache[$Path]
    if ($hit -and $hit.Time -eq $item.LastWriteTime -and $hit.Size -eq $item.Length) { return $hit.Value }
    $value = Read-Json $Path
    if ($value) { $script:JsonCache[$Path] = @{ Time = $item.LastWriteTime; Size = $item.Length; Value = $value } }
    return $value
}

function Write-Json([string]$Path, $Object) {
    # Erst in eine Temp-Datei schreiben, dann ersetzen: So liest der Server nie eine halbe Datei.
    $tmp = "$Path.tmp"
    Write-Text $tmp (ConvertTo-Json -InputObject $Object -Depth 8)
    for ($i = 0; $i -lt 10; $i++) {
        try { Move-Item -LiteralPath $tmp -Destination $Path -Force -ErrorAction Stop; return } catch { Start-Sleep -Milliseconds 100 }
    }
}

function Add-HubLog([string]$Message) {
    $path = Get-HubPath 'state\worker.log'
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    try {
        if ((Test-Path -LiteralPath $path) -and (Get-Item -LiteralPath $path).Length -gt 1MB) {
            Move-Item -LiteralPath $path -Destination "$path.1" -Force
        }
        [IO.File]::AppendAllText($path, "$line`r`n", $script:Utf8NoBom)
    } catch { }
}

function Get-HubConfig { Read-Json (Get-HubPath 'config.json') }

function Resolve-Git {
    $cmd = Get-Command git -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return 'C:\Program Files\Git\cmd\git.exe'
}

function Resolve-GodotBin($Config) {
    if ($Config.godotBin -and (Test-Path -LiteralPath $Config.godotBin)) { return $Config.godotBin }
    # Nach einem winget-Update ändert sich der Pfad: dann die neueste Konsolenversion suchen.
    $found = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Directory -Filter 'GodotEngine.GodotEngine*' -ErrorAction SilentlyContinue |
        ForEach-Object { Get-ChildItem $_.FullName -Filter 'Godot_*_console.exe' -ErrorAction SilentlyContinue } |
        Sort-Object Name -Descending | Select-Object -First 1
    if ($found) { return $found.FullName }
    return 'godot'
}

function Invoke-Git([string]$Dir, [string[]]$GitArgs) {
    if (-not $script:Git) { $script:Git = Resolve-Git }
    $out = & $script:Git -C $Dir @GitArgs 2>&1 | ForEach-Object { "$_" }
    [pscustomobject]@{ Code = $LASTEXITCODE; Output = (@($out) -join "`n").Trim() }
}

## Gestapeltes Ticket: Holt die Branches der Vorgänger aus "after:", die noch auf den Review
## warten, in den aktuellen Branch. Gemergte Vorgänger stecken schon in main (ihr Branch ist
## gelöscht) und werden übersprungen. Gibt die einbezogenen IDs zurück; wirft bei Konflikt.
function Merge-StackedBases([string]$Workspace, $Ticket) {
    $merged = @()
    foreach ($dep in (Get-AfterIds $Ticket)) {
        if ((Invoke-Git $Workspace @('rev-parse', '--verify', '-q', "agent/$dep")).Code -ne 0) { continue }
        $r = Invoke-Git $Workspace @('-c', 'user.name=Lokaler Agent', '-c', 'user.email=agent@localhost',
            'merge', '--no-ff', '-q', '-m', "Basis: agent/$dep (noch im Review)", "agent/$dep")
        if ($r.Code -ne 0) {
            Invoke-Git $Workspace @('merge', '--abort') | Out-Null
            throw "Vorgänger agent/$dep lässt sich nicht einbeziehen (Konflikt?): $($r.Output)"
        }
        $merged += $dep
    }
    return ,$merged
}

## Probe-Merge ohne etwas zu ändern (git merge-tree): Lässt sich $Branch konfliktfrei mit dem
## Basis-Branch und den übrigen agent/*-Branches im Review zusammenführen? Ein Hinweis je Konflikt.
function Get-ConflictWarnings([string]$Dir, [string]$Branch, [string]$BaseBranch) {
    $others = @($BaseBranch) + @((Invoke-Git $Dir @('branch', '--list', 'agent/*', '--format=%(refname:short)')).Output -split "`n" |
        ForEach-Object { $_.Trim() } | Where-Object { $_ -and $_ -ne $Branch })
    $warnings = @()
    foreach ($other in $others) {
        $r = Invoke-Git $Dir @('merge-tree', '--write-tree', '--name-only', '--no-messages', $Branch, $other)
        if ($r.Code -ne 1) { continue }   # 0 = konfliktfrei, sonst Fehler (z. B. Branch inzwischen gelöscht)
        # Erste Zeile ist der Baum, danach die Dateien mit Konflikt.
        $files = @($r.Output -split "`n" | Select-Object -Skip 1 | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Select-Object -Unique)
        $warnings += "Merge-Konflikt mit ``$other`` in $($files -join ', '). Die Tickets waren nicht verkettet: beim Mergen auflösen."
    }
    return ,$warnings
}

## Zahl der bestandenen Tests aus der Prüfausgabe, laut Muster "testCount" des Projekts in
## config.json (erste Klammer = Anzahl). $null: Projekt hat kein Muster. -1: nicht genau eine Ergebniszeile.
function Get-TestCount($Project, [string]$Output) {
    if (-not $Project.testCount) { return $null }
    $found = [regex]::Matches("$Output", $Project.testCount, 'Multiline')
    if ($found.Count -ne 1) { return -1 }
    return [int]$found[0].Groups[1].Value
}

function Test-Ollama($Config) {
    try { Invoke-RestMethod -Uri "$($Config.ollamaUrl)/api/version" -TimeoutSec 3 | Out-Null; return $true } catch { return $false }
}

function Enter-SingleInstance([string]$Name) {
    $created = $false
    $script:InstanceMutex = New-Object System.Threading.Mutex($true, "Local\AgentHub_$Name", [ref]$created)
    return $created
}

function Get-ProcessAlive($ProcessId) {
    if (-not $ProcessId) { return $false }
    $proc = Get-Process -Id ([int]$ProcessId) -ErrorAction SilentlyContinue
    return [bool]($proc -and $proc.ProcessName -eq 'powershell')
}

# --- Tickets -----------------------------------------------------------------
# Ein Ticket ist eine Markdown-Datei mit Kopfbereich:
#   ---
#   id: T-0001
#   title: Kurzer Titel
#   project: testspiel
#   priority: 3          (1 = dringend ... 5 = irgendwann)
#   after: T-0000, T-0001 (optional: erst starten, wenn diese Tickets erledigt sind)
#   ---
# Die Spalte (todo/doing/review/failed/done) ergibt sich aus dem Ordner.

function Read-Ticket([string]$Path) {
    $text = Read-Text $Path
    if ($null -eq $text) { return $null }
    $meta = @{}
    $body = $text
    if ($text -match '(?s)^\uFEFF?\s*---[ \t]*\r?\n(.*?)\r?\n---[ \t]*(?:\r?\n|$)(.*)$') {
        $front = $Matches[1]
        $body = $Matches[2]
        foreach ($line in ($front -split '\r?\n')) {
            if ($line -match '^\s*([A-Za-z_]+)\s*:\s*(.*?)\s*$') {
                $key = $Matches[1].ToLower()
                $value = $Matches[2] -replace '\s+#\s.*$', ''
                $meta[$key] = ($value.Trim() -replace '^["'']|["'']$', '')
            }
        }
    }
    $file = Split-Path -Leaf $Path
    $id = $meta['id']
    if (-not $id) { $id = $file -replace '^(T-\d+).*$', '$1' }
    $title = $meta['title']
    if (-not $title) { $title = $file }
    $priority = 3
    if ($meta['priority'] -match '^\d+$') { $priority = [int]$meta['priority'] }
    $maxAttempts = 0
    if ($meta['max_attempts'] -match '^\d+$') { $maxAttempts = [int]$meta['max_attempts'] }
    $timeout = 0
    if ($meta['timeout_minutes'] -match '^\d+$') { $timeout = [int]$meta['timeout_minutes'] }
    [pscustomobject]@{
        Id          = $id
        Title       = $title
        Project     = $meta['project']
        Priority    = $priority
        Model       = $meta['model']
        Verify      = $meta['verify']
        After       = $meta['after']
        MaxAttempts = $maxAttempts
        TimeoutMinutes = $timeout
        Body        = $body.Trim()
        Path        = $Path
        File        = $file
        Column      = Split-Path -Leaf (Split-Path -Parent $Path)
        Modified    = (Get-Item -LiteralPath $Path).LastWriteTime
    }
}

$script:TicketCache = @{}   # Spalte -> @{ Pfad -> Ticket }

# Rückgabe wird ausgerollt: Aufrufer schreiben @(Get-Tickets 'todo').
# Worker und Server fragen ständig alle Spalten ab: Eine Datei wird nur neu gelesen, wenn sie sich
# geändert hat. Die Ticket-Objekte werden dabei geteilt, also nie verändern.
function Get-Tickets([string]$Column) {
    $dir = Get-HubPath "tickets\$Column"
    if (-not (Test-Path -LiteralPath $dir)) { return }
    $old = $script:TicketCache[$Column]
    $new = @{}
    foreach ($file in @(Get-ChildItem -LiteralPath $dir -Filter '*.md' -File)) {
        $hit = $null
        if ($old) { $hit = $old[$file.FullName] }
        # Zeit vor dem Lesen merken: Ändert sich die Datei währenddessen, wird sie beim nächsten Mal neu gelesen.
        if ($hit -and $hit.Time -eq $file.LastWriteTime) { $ticket = $hit.Ticket }
        else { $ticket = Read-Ticket $file.FullName }
        if ($ticket) { $new[$file.FullName] = @{ Time = $file.LastWriteTime; Ticket = $ticket }; $ticket }
    }
    $script:TicketCache[$Column] = $new
}

function Find-Ticket([string]$Id) {
    foreach ($column in $script:Columns) {
        foreach ($ticket in @(Get-Tickets $column)) { if ($ticket.Id -eq $Id) { return $ticket } }
    }
    return $null
}

function Move-Ticket($Ticket, [string]$Column) {
    $dest = Get-HubPath "tickets\$Column\$($Ticket.File)"
    Move-Item -LiteralPath $Ticket.Path -Destination $dest -Force -ErrorAction Stop
    Read-Ticket $dest
}

function Get-RunDir([string]$Id) { Get-HubPath "runs\$Id" }

## IDs aus "after:" (durch Komma oder Leerzeichen getrennt).
function Get-AfterIds($Ticket) {
    return @(($Ticket.After -split '[,\s]+') | Where-Object { $_ })
}

## Medien-Aufträge (medien/A-0001-kurzname.md): Bilder, Videos oder Audio, die Claude im Review mit
## Higgsfield erzeugt (CLAUDE.md, "Medien mit Higgsfield"). Tickets warten per "after: A-0001" darauf.
function Get-MediaRequests {
    $dir = Get-HubPath 'medien'
    if (-not (Test-Path -LiteralPath $dir)) { return }
    Get-ChildItem -LiteralPath $dir -Filter 'A-*.md' -File | ForEach-Object {
        $meta = (Split-FrontMatter (Read-Text $_.FullName)).Meta
        $id = "$($meta['id'])"
        if (-not $id) { $id = $_.Name -replace '^(A-\d+).*$', '$1' }
        $attempted = $null
        if ($meta['attempted']) { try { $attempted = [datetime]::Parse("$($meta['attempted'])") } catch { } }
        [pscustomobject]@{
            Id = $id; Title = "$($meta['title'])"; Project = "$($meta['project'])"; Kind = "$($meta['kind'])"
            Status = "$($meta['status'])".ToLower(); Attempted = $attempted; File = $_.Name
        }
    }
}

## Offene Punkte für ChatGPT (lastenhefte/punkte/P-0001-kurzname.md): Fragen und Aufgaben zum Ansehen
## oder Ausprobieren, die Claude stellt. ChatGPT beantwortet sie oder gibt sie an den Nutzer weiter;
## erledigte verschiebt Claude nach punkte/erledigt (CLAUDE.md, "Offene Punkte für ChatGPT").
function Get-Punkte {
    $dir = Get-HubPath 'lastenhefte\punkte'
    if (-not (Test-Path -LiteralPath $dir)) { return }
    Get-ChildItem -LiteralPath $dir -Filter 'P-*.md' -File | ForEach-Object {
        $parts = Split-FrontMatter (Read-Text $_.FullName)
        $meta = $parts.Meta
        $id = "$($meta['id'])"
        if (-not $id) { $id = $_.Name -replace '^(P-\d+).*$', '$1' }
        $title = $_.BaseName
        if ($parts.Body -match '(?m)^#\s+(.+?)\s*$') { $title = $Matches[1] }
        [pscustomobject]@{
            Id = $id; Title = $title; Kind = "$($meta['art'])".ToLower(); Status = "$($meta['status'])".ToLower()
            Projects = @("$($meta['projekt'])" -split '[,\s]+' | Where-Object { $_ }); File = $_.Name
        }
    }
}

## Nachricht an den Nutzer: Windows-Meldung auf dem PC und, wenn in config.json unter
## benachrichtigung.ntfy eine Adresse steht (z. B. https://ntfy.sh/<geheimes-thema>), per ntfy aufs Handy.
function Send-HubNachricht([string]$Titel, [string]$Text) {
    try {
        $null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
        $null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
        $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $xml.LoadXml("<toast><visual><binding template='ToastGeneric'><text>$([Security.SecurityElement]::Escape($Titel))</text><text>$([Security.SecurityElement]::Escape($Text))</text></binding></visual></toast>")
        $appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show([Windows.UI.Notifications.ToastNotification]::new($xml))
    } catch { Add-HubLog "Windows-Meldung fehlgeschlagen: $($_.Exception.Message)" }
    $ntfy = "$((Get-HubConfig).benachrichtigung.ntfy)"
    if ($ntfy -match '^(https?://[^/]+)/([A-Za-z0-9_-]+)$') {
        try {
            $body = ConvertTo-Json @{ topic = $Matches[2]; title = $Titel; message = $Text; tags = @('robot') }
            Invoke-RestMethod -Uri $Matches[1] -Method Post -ContentType 'application/json; charset=utf-8' `
                -Body ([Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 15 | Out-Null
        } catch { Add-HubLog "ntfy-Nachricht fehlgeschlagen: $($_.Exception.Message)" }
    }
}

## Meldet Neues, das auf den Nutzer wartet (Worker, etwa jede Minute): Punkte, die ChatGPT an ihn
## weitergegeben hat, und ein Ollama, das seit 30 Minuten nicht antwortet. state\benachrichtigt.json
## merkt sich, was schon gemeldet wurde.
function Update-Benachrichtigungen([bool]$OllamaOk = $true) {
    $file = Get-HubPath 'state\benachrichtigt.json'
    $state = Read-Json $file
    $known = @(); $ollamaDownSince = $null; $ollamaReported = $false
    if ($state) {
        $known = @($state.punkte)
        if ($state.ollamaDownSince) { $ollamaDownSince = [datetime]::Parse("$($state.ollamaDownSince)") }
        $ollamaReported = [bool]$state.ollamaReported
    }
    $forUser = @(Get-Punkte | Where-Object { $_.Status -eq 'weitergegeben' } | Sort-Object Id)
    $new = @($forUser | Where-Object { $known -notcontains $_.Id })
    if ($new.Count -gt 0) {
        $titel = if ($new.Count -eq 1) { 'Agent Hub: 1 Punkt für dich' } else { "Agent Hub: $($new.Count) Punkte für dich" }
        Send-HubNachricht $titel ((@($new | ForEach-Object { "$($_.Id) $($_.Title)" }) -join '; ') + '. Details im Dashboard oder bei ChatGPT.')
        Add-HubLog "Benachrichtigung: $(@($new | ForEach-Object { $_.Id }) -join ', ') für den Nutzer"
    }
    if ($OllamaOk) {
        if ($ollamaReported) { Send-HubNachricht 'Agent Hub: Ollama läuft wieder' 'Die Agents arbeiten weiter.' }
        $ollamaDownSince = $null; $ollamaReported = $false
    } else {
        if (-not $ollamaDownSince) { $ollamaDownSince = Get-Date }
        if (-not $ollamaReported -and ((Get-Date) - $ollamaDownSince).TotalMinutes -ge 30) {
            Send-HubNachricht 'Agent Hub: Ollama antwortet nicht' 'Seit 30 Minuten ist Ollama nicht erreichbar, die Agents stehen still. Läuft die Ollama-App?'
            $ollamaReported = $true
        }
    }
    Write-Json $file ([ordered]@{
        punkte = @($forUser | ForEach-Object { $_.Id })
        ollamaDownSince = $(if ($ollamaDownSince) { $ollamaDownSince.ToString('o') } else { $null })
        ollamaReported = $ollamaReported
    })
}

## IDs, auf die ein Ticket aufbauen darf: Tickets erledigt (gemergt) oder Prüfung bestanden
## (liegt in review; dann baut der Worker auf ihrem Branch auf) und fertige Medien-Aufträge.
function Get-ReadyIds {
    $tickets = @((@(Get-Tickets 'done') + @(Get-Tickets 'review')) | ForEach-Object { $_.Id })
    $media = @(Get-MediaRequests | Where-Object { $_.Status -eq 'fertig' } | ForEach-Object { $_.Id })
    return @($tickets + $media)
}

## Nächstes startbares Ticket aus todo, nach Priorität und ID.
function Get-NextTicket {
    $ready = Get-ReadyIds
    @(Get-Tickets 'todo') | Where-Object {
        $missing = @(Get-AfterIds $_ | Where-Object { $ready -notcontains $_ })
        $missing.Count -eq 0
    } | Sort-Object Priority, Id | Select-Object -First 1
}

## Braucht es jetzt einen Review-Durchgang? Die Review-Aufgabe läuft stündlich und fragt zuerst
## hub\review-gate.ps1, damit Claude nur kommt, wenn es etwas zu tun gibt (CLAUDE.md, "Review-Durchgang").
## Grenzen aus "reviewGate" in config.json. Rückgabe: Needed (ja/nein) und Reasons (Gründe als Text).
function Get-ReviewNeed([datetime]$Now = (Get-Date)) {
    $gate = (Get-HubConfig).reviewGate
    $minOpen = 15; $minOpenNoon = 40; $maxReview = 20; $pause = @('12:30', '21:00'); $mediaRetry = 6
    if ($gate) {
        if ($gate.mediaRetryHours) { $mediaRetry = [double]$gate.mediaRetryHours }
        if ($gate.minOpen) { $minOpen = [int]$gate.minOpen }
        if ($gate.minOpenNoon) { $minOpenNoon = [int]$gate.minOpenNoon }
        if ($gate.maxReview) { $maxReview = [int]$gate.maxReview }
        if (@($gate.pause).Count -eq 2) { $pause = @($gate.pause) }
    }
    $no = { param($Why) [pscustomobject]@{ Needed = $false; Reasons = @($Why) } }

    # Ein Review läuft noch (Sperre älter als 2 Stunden gilt als liegen geblieben).
    $lock = Read-Json (Get-HubPath 'state\review.lock')
    if ($lock -and $lock.started) {
        $started = [datetime]::Parse("$($lock.started)")
        if (($Now - $started).TotalHours -lt 2) { return & $no "Ein Review läuft noch (seit $($started.ToString('HH:mm')) Uhr)." }
    }
    # Stoßzeit: Auch nachgeholte Läufe (PC hat geschlafen) warten bis zum Ende der Pause.
    $minute = $Now.Hour * 60 + $Now.Minute
    $from, $to = $pause | ForEach-Object { $p = "$_" -split ':'; [int]$p[0] * 60 + [int]$p[1] }
    $inPause = if ($from -le $to) { $minute -ge $from -and $minute -lt $to } else { $minute -ge $from -or $minute -lt $to }
    if ($inPause) { return & $no "Stoßzeit ($($pause[0])–$($pause[1]) Uhr), kein Review." }

    $reasons = New-Object System.Collections.ArrayList
    foreach ($spec in @(Get-Lastenhefte)) {
        if ($spec.Status -eq 'bereit') { [void]$reasons.Add("Lastenheft $($spec.File) ist freigegeben.") }
        if ($spec.NewFeedback -gt 0 -and @('entwurf', 'pausiert') -notcontains $spec.Status) {
            [void]$reasons.Add("$($spec.NewFeedback) neue Rückmeldung(en) in $($spec.File).")
        }
    }
    # Medien-Aufträge: neue sofort, solche, für die die Credits nicht reichten, frühestens nach $mediaRetry Stunden.
    $media = @(Get-MediaRequests | Where-Object { $_.Status -eq 'offen' })
    $newMedia = @($media | Where-Object { -not $_.Attempted })
    $retryMedia = @($media | Where-Object { $_.Attempted -and ($Now - $_.Attempted).TotalHours -ge $mediaRetry })
    if ($newMedia.Count -gt 0) { [void]$reasons.Add("$($newMedia.Count) neue(r) Medien-Auftrag/-Aufträge.") }
    if ($retryMedia.Count -gt 0) { [void]$reasons.Add("$($retryMedia.Count) Medien-Auftrag/-Aufträge warten auf Credits, neuer Versuch.") }
    $answered = @(Get-Punkte | Where-Object { $_.Status -eq 'beantwortet' })
    if ($answered.Count -gt 0) { [void]$reasons.Add("$($answered.Count) Punkt(e) beantwortet ($(@($answered | ForEach-Object { $_.Id }) -join ', ')).") }
    $failed = @(Get-Tickets 'failed').Count
    if ($failed -gt 0) { [void]$reasons.Add("$failed Ticket(s) fehlgeschlagen.") }
    $review = @(Get-Tickets 'review').Count
    if ($review -ge $maxReview) { [void]$reasons.Add("$review Tickets warten auf den Review.") }
    $last = $null
    $lastReview = Read-Json (Get-HubPath 'state\last-review.json')
    if ($lastReview -and $lastReview.finished) { $last = [datetime]::Parse("$($lastReview.finished)") }
    $orders = Get-Item -LiteralPath (Get-HubPath 'auftraege.md') -ErrorAction SilentlyContinue
    if ($orders -and (-not $last -or $orders.LastWriteTime -gt $last)) { [void]$reasons.Add('auftraege.md wurde seit dem letzten Review geändert.') }
    # Vorrat knapp: Nachplanen lohnt nur, wenn seit dem letzten Review Tickets fertig geworden sind.
    # Sonst konnte schon der letzte Review nicht mehr planen (Projekt wartet z. B. auf den Nutzer).
    # Mittags immer, weil danach die Pause bis 21 Uhr kommt.
    $open = @(Get-Tickets 'todo').Count + @(Get-Tickets 'doing').Count
    $noon = ($Now.Hour -eq 12)
    $target = if ($noon) { $minOpenNoon } else { $minOpen }
    if ($open -lt $target -and ($noon -or $review -gt 0)) {
        [void]$reasons.Add("Vorrat knapp: $open offene Tickets (Ziel mindestens $target), $review warten auf den Review.")
    }
    if ($reasons.Count -eq 0) {
        return & $no "Nichts zu tun: $open offene Tickets, $review im Review, keine neuen Rückmeldungen."
    }
    [pscustomobject]@{ Needed = $true; Reasons = @($reasons) }
}

function Format-Duration($Seconds) {
    if ($null -eq $Seconds) { return '–' }
    $s = [int]$Seconds
    if ($s -lt 3600) { return '{0}:{1:00} min' -f [math]::Floor($s / 60), ($s % 60) }
    return '{0} Std {1} min' -f [math]::Floor($s / 3600), [math]::Floor(($s % 3600) / 60)
}

# --- Projekte und Lastenhefte ---------------------------------------------------
# ChatGPT schreibt Lastenhefte nach lastenhefte/<projekt>.md (Vorlage: VORLAGE.md).
# Status ab "warteschlange" setzt nur Claude (siehe CLAUDE.md, "Projekt-Warteschlange").

$script:ProjectStates = [ordered]@{
    'aktiv'           = 'In Arbeit'
    'wartet-auf-dich' = 'Wartet auf dich'
    'rueckfrage'      = 'Rückfrage an dich'
    'warteschlange'   = 'Warteschlange'
    'bereit'          = 'Freigegeben'
    'entwurf'         = 'Entwurf bei ChatGPT'
    'pausiert'        = 'Pausiert'
    'fertig'          = 'Fertig'
}
$script:SpecHelperFiles = @('AGENTS.md', 'VORLAGE.md', 'STATUS.md')
$script:StatusHash = $null
$script:StatusWritten = [datetime]::MinValue

## Kopfbereich (--- key: value ---) und Rest eines Markdown-Texts.
function Split-FrontMatter([string]$Text) {
    $meta = @{}
    $body = "$Text"
    if ($body -match '(?s)^﻿?\s*---[ \t]*\r?\n(.*?)\r?\n---[ \t]*(?:\r?\n|$)(.*)$') {
        $front = $Matches[1]
        $body = $Matches[2]
        foreach ($line in ($front -split '\r?\n')) {
            if ($line -match '^\s*([A-Za-z_]+)\s*:\s*(.*?)\s*$') {
                $key = $Matches[1].ToLower()
                $value = $Matches[2] -replace '\s+#\s.*$', ''
                $meta[$key] = ($value.Trim() -replace '^["'']|["'']$', '')
            }
        }
    }
    return @{ Meta = $meta; Body = $body }
}

## Inhalt eines "## Überschrift"-Abschnitts (ohne HTML-Kommentare).
function Get-MarkdownSection([string]$Body, [string]$Heading) {
    $pattern = '(?ms)^##[ \t]+' + [regex]::Escape($Heading) + '[ \t]*$(.*?)(?=^##[ \t]|\z)'
    if ($Body -match $pattern) { return ($Matches[1] -replace '(?s)<!--.*?-->', '').Trim() }
    return ''
}

## Alle Lastenhefte (ohne AGENTS.md, VORLAGE.md, STATUS.md).
function Get-Lastenhefte {
    $dir = Get-HubPath 'lastenhefte'
    if (-not (Test-Path -LiteralPath $dir)) { return }
    Get-ChildItem -LiteralPath $dir -Filter '*.md' -File | Where-Object { $script:SpecHelperFiles -notcontains $_.Name } | ForEach-Object {
        $parts = Split-FrontMatter (Read-Text $_.FullName)
        $meta = $parts.Meta
        $name = "$($meta['projekt'])"
        if (-not $name) { $name = $_.BaseName }
        $status = "$($meta['status'])".ToLower()
        if (-not $script:ProjectStates.Contains($status)) { $status = 'entwurf' }
        $priority = 2
        if ($meta['prioritaet'] -match '^\d+$') { $priority = [int]$meta['prioritaet'] }
        $title = $meta['titel']
        if (-not $title) { $title = $name }
        $questions = Get-MarkdownSection $parts.Body 'Offene Fragen'
        if ($questions -match '^\s*-\s*\(keine\)\s*$') { $questions = '' }
        [pscustomobject]@{
            Name = $name; Title = $title; Status = $status; Priority = $priority
            Created = "$($meta['erstellt'])"; Ablaufplan = ("$($meta['ablaufplan'])" -ne 'nein')
            File = $_.Name; Modified = $_.LastWriteTime; Questions = $questions
            NewFeedback = [regex]::Matches($parts.Body, '(?m)^\s*-\s*\d{4}-\d{2}-\d{2}\s*\(neu\)').Count
        }
    }
}

## Fortschritt eines Projekts laut Ablaufplan: Tickets, Meilensteine und die Aufgaben zum
## Ausprobieren, die schon anstehen (Tickets des Meilensteins sind erledigt). ReadyTasks erledigt
## zuerst ChatGPT per Computer Use; UserTasks ("who": "nutzer") hat ChatGPT an den Nutzer weitergegeben.
function Get-PlanProgress([string]$Project) {
    $plan = Read-Json (Get-HubPath "plans\$Project.json")
    if (-not $plan) { return $null }
    $columnOf = @{}
    foreach ($column in $script:Columns) {
        foreach ($ticket in @(Get-Tickets $column)) { if ($ticket.Project -eq $Project) { $columnOf[$ticket.Id] = $column } }
    }
    $done = 0; $total = 0; $milestonesDone = 0; $milestones = 0; $remaining = 0
    $readyTasks = @(); $userTasks = @()
    foreach ($m in @($plan.milestones)) {
        if (-not $m) { continue }
        $milestones++
        $ids = @(@($m.tickets) | Where-Object { $_ -and $columnOf.ContainsKey($_) })
        $msDone = @($ids | Where-Object { $columnOf[$_] -eq 'done' }).Count
        $total += $ids.Count
        $done += $msDone
        # Restarbeit: offene Tickets plus der noch nicht zerlegte Teil der Schätzung.
        $remaining += $ids.Count - $msDone
        if (-not $m.done -and "$($m.estimate)" -match '^\d+$' -and [int]$m.estimate -gt $ids.Count) { $remaining += [int]$m.estimate - $ids.Count }
        $ticketsFinished = ($ids.Count -gt 0 -and $msDone -eq $ids.Count) -or ($ids.Count -eq 0 -and $m.done)
        $openTasks = @(@($m.tasks) | Where-Object { $_ -and -not $_.done })
        if ($ticketsFinished -and $openTasks.Count -eq 0) { $milestonesDone++ }
        if ($ticketsFinished) {
            foreach ($task in $openTasks) {
                if ("$($task.who)" -eq 'nutzer') { $userTasks += "$($m.title): $($task.text)" } else { $readyTasks += "$($m.title): $($task.text)" }
            }
        }
    }
    [pscustomobject]@{
        Done = $done; Total = $total; MilestonesDone = $milestonesDone; Milestones = $milestones; Remaining = $remaining
        ReadyTasks = $readyTasks; UserTasks = $userTasks; Visible = ($plan.visible -ne $false); Target = $plan.target
    }
}

## Schreibt lastenhefte/STATUS.md für ChatGPT: Warteschlange, Fortschritt, Fragen an den Nutzer.
## Nur wenn sich etwas geändert hat (sonst höchstens alle 30 Minuten wegen der Uhrzeit).
function Update-StatusFile {
    $dir = Get-HubPath 'lastenhefte'
    if (-not (Test-Path -LiteralPath $dir)) { return }
    $specs = @(Get-Lastenhefte | Sort-Object Priority, Created, Name)
    $worker = Read-Json (Get-HubPath 'state\worker.json')
    $lines = New-Object System.Collections.ArrayList
    $add = { param($text) [void]$lines.Add($text) }

    # Frühwarnung: Nach dem aktiven Projekt wartet kein Lastenheft, und seine Arbeit geht bald aus.
    $active = $specs | Where-Object { $_.Status -eq 'aktiv' } | Select-Object -First 1
    $queued = @($specs | Where-Object { @('warteschlange', 'bereit') -contains $_.Status }).Count
    if ($queued -eq 0) {
        $activeProgress = $null
        if ($active) { $activeProgress = Get-PlanProgress $active.Name }
        if (-not $active) {
            & $add '## Keine Arbeit für die Agents'
            & $add ''
            & $add 'Gerade ist kein Projekt in Arbeit und keins in der Warteschlange, die Agents stehen still. Bitte sprich mit dem Nutzer über das nächste Projekt und lege ein Lastenheft an.'
            & $add ''
        } elseif ($activeProgress -and $activeProgress.Remaining -le 60) {
            & $add '## Bald keine Arbeit mehr für die Agents'
            & $add ''
            & $add "Für **$($active.Title)** bleiben noch etwa $($activeProgress.Remaining) Tickets. Das reicht den Agents höchstens für etwa einen Tag, und danach wartet kein weiteres Lastenheft. Bitte sprich mit dem Nutzer über das nächste Projekt und lege ein Lastenheft an, damit die Agents nicht stillstehen."
            & $add ''
        }
    }

    $sections = @(
        @{ States = @('aktiv'); Title = 'In Arbeit' },
        @{ States = @('wartet-auf-dich', 'rueckfrage'); Title = 'Wartet auf eine Antwort (von dir, sonst vom Nutzer)' },
        @{ States = @('warteschlange'); Title = 'Warteschlange (in dieser Reihenfolge)' },
        @{ States = @('bereit'); Title = 'Freigegeben, wird beim nächsten Review übernommen' },
        @{ States = @('entwurf'); Title = 'Entwürfe (noch nicht freigegeben)' },
        @{ States = @('pausiert'); Title = 'Pausiert' },
        @{ States = @('fertig'); Title = 'Fertig' }
    )
    # Offene Punkte zuerst: das ist ChatGPTs Arbeitsliste (lastenhefte/AGENTS.md).
    $punkte = @(Get-Punkte | Sort-Object Id)
    $forChatGpt = @($punkte | Where-Object { $_.Status -eq 'offen' })
    $forUser = @($punkte | Where-Object { $_.Status -eq 'weitergegeben' })
    $waiting = @($punkte | Where-Object { $_.Status -eq 'beantwortet' })
    $kinds = @{ frage = 'Frage'; ansehen = 'Ansehen'; ausprobieren = 'Ausprobieren (Computer Use)' }
    $punktLine = { param($p) $k = $kinds[$p.Kind]; if (-not $k) { $k = $p.Kind }; "- **$($p.Id)** $($p.Title) ($k; $($p.Projects -join ', ')) → ``punkte/$($p.File)``" }
    if ($forChatGpt.Count -gt 0) {
        & $add '## Für dich, ChatGPT: offene Punkte'
        & $add ''
        & $add 'Erledige sie selbst (siehe AGENTS.md): Antwort bzw. Ergebnis in die Datei schreiben und `status: beantwortet` setzen. Was du nicht kannst oder nicht entscheiden darfst: Grund eintragen, `status: weitergegeben`, dem Nutzer Bescheid geben.'
        & $add ''
        foreach ($p in $forChatGpt) { & $add (& $punktLine $p) }
        & $add ''
    }
    if ($forUser.Count -gt 0) {
        & $add '## Nur für den Nutzer (von dir weitergegeben)'
        & $add ''
        foreach ($p in $forUser) { & $add (& $punktLine $p) }
        & $add ''
    }
    if ($waiting.Count -gt 0) {
        & $add "Beantwortet, Claude setzt es beim nächsten Review um: $(@($waiting | ForEach-Object { $_.Id }) -join ', ')"
        & $add ''
    }

    foreach ($section in $sections) {
        $items = @($specs | Where-Object { $section.States -contains $_.Status })
        if ($items.Count -eq 0) { continue }
        & $add "## $($section.Title)"
        & $add ''
        $n = 0
        foreach ($spec in $items) {
            $n++
            $prefix = if ($section.States -contains 'warteschlange') { "$n." } else { '-' }
            $info = "$prefix **$($spec.Title)** (``$($spec.File)``, Status ``$($spec.Status)``)"
            $progress = Get-PlanProgress $spec.Name
            if ($progress -and $progress.Total -gt 0) {
                $info += ": $($progress.Done) von $($progress.Total) Tickets erledigt, $($progress.MilestonesDone) von $($progress.Milestones) Meilensteinen fertig"
            }
            if ($worker -and $worker.state -eq 'working' -and $worker.project -eq $spec.Name) {
                $info += ". Gerade in Arbeit: $($worker.ticket) $($worker.title)"
            }
            if ($spec.NewFeedback -gt 0) { $info += ". $($spec.NewFeedback) neue Rückmeldung(en), werden beim nächsten Review übernommen" }
            $open = @($punkte | Where-Object { $_.Projects -contains $spec.Name -and @('offen', 'weitergegeben') -contains $_.Status })
            if ($open.Count -gt 0) { $info += ". Offene Punkte: $(@($open | ForEach-Object { $_.Id }) -join ', ')" }
            & $add $info
        }
        & $add ''
    }
    if ($specs.Count -eq 0) { & $add 'Noch keine Lastenhefte.'; & $add '' }
    $cfg = Get-HubConfig
    $short = { param($t) if ("$t" -match '^(\d{1,2}):(\d{2})$') { if ($Matches[2] -eq '00') { "$([int]$Matches[1])" } else { "$([int]$Matches[1]):$($Matches[2])" } } else { "$t" } }
    if ($cfg.reviewGate -and @($cfg.reviewGate.pause).Count -eq 2) {
        $pause = @($cfg.reviewGate.pause | ForEach-Object { & $short $_ })
        & $add "Claude schaut bei Bedarf stündlich vorbei, außer zwischen $($pause[0]) und $($pause[1]) Uhr. Live-Ansicht: http://localhost:8787"
    } else {
        $times = @($cfg.reviewTimes) | ForEach-Object { & $short $_ }
        & $add "Claude schaut um $($times -join ', ') Uhr vorbei. Live-Ansicht: http://localhost:8787"
    }

    $content = ($lines -join "`r`n") + "`r`n"
    $hash = $content.GetHashCode()
    if ($hash -eq $script:StatusHash -and ((Get-Date) - $script:StatusWritten).TotalMinutes -lt 30) { return }
    $header = "# Stand des Agent Hub`r`n`r`nAutomatisch erzeugt am $(Get-Date -Format 'dd.MM.yyyy, HH:mm') Uhr. Nicht bearbeiten, wird laufend neu geschrieben.`r`n`r`n"
    Write-Text (Join-Path $dir 'STATUS.md') ($header + $content)
    $script:StatusHash = $hash
    $script:StatusWritten = Get-Date
}
