# Nächtliche Sicherung nach GitHub (privates Repo, Adresse in config.json unter backup.url).
#   - jedes Projekt-Repo: main  -> Branch projekt/<name>
#   - der Hub selbst (Anleitungen, Lastenhefte, Punkte, Tickets, Pläne, Medien-Aufträge, Protokolle, Skripte,
#     ohne projects, workspaces, envs, runs und state) -> Branch hub, als eigener Verlauf in state\backup-hub.git
# Der Wächter (launch.ps1 -Watchdog) startet sie, wenn die letzte Sicherung älter als 23 Stunden ist.
# Ergebnis in state\last-backup.json und worker.log. Beim ersten Mal von Hand starten, damit Git
# die Anmeldung bei GitHub abfragen kann:
#   powershell -NoProfile -ExecutionPolicy Bypass -File hub\backup.ps1
param([switch]$WennFaellig, [string]$Url = '', [string]$StatusDatei = '')

. (Join-Path $PSScriptRoot 'common.ps1')
$ErrorActionPreference = 'Continue'
$cfg = Get-HubConfig
$url = if ($Url) { $Url } else { "$($cfg.backup.url)" }
$statusFile = if ($StatusDatei) { $StatusDatei } else { Get-HubPath 'state\last-backup.json' }
$last = Read-Json $statusFile

if (-not $url) {
    if (-not $WennFaellig) { Write-Host 'Keine Sicherung: In config.json fehlt backup.url.' }
    exit 0
}
if ($WennFaellig -and $last -and $last.finished) {
    try { if (((Get-Date) - [datetime]::Parse("$($last.finished)")).TotalHours -lt 23) { exit 0 } } catch { }
}
if (-not (Enter-SingleInstance 'Backup')) { Write-Host 'Eine Sicherung läuft bereits.'; exit 0 }

$git = Resolve-Git
$problems = @()
$done = @()

foreach ($name in @($cfg.projects.PSObject.Properties.Name)) {
    $path = $cfg.projects.$name.path
    if (-not (Test-Path -LiteralPath (Join-Path $path '.git'))) { continue }
    $branch = $cfg.projects.$name.baseBranch
    $out = & $git -C $path push --force --quiet $url "refs/heads/${branch}:refs/heads/projekt/$name" 2>&1
    if ($LASTEXITCODE -eq 0) { $done += $name } else { $problems += "${name}: $((@($out) -join ' ').Trim())" }
}

# Hub-Dateien als eigener Verlauf (eigenes Git-Verzeichnis, damit der Hub-Ordner selbst kein Repo wird).
$gitDir = Get-HubPath 'state\backup-hub.git'
$hubArgs = @("--git-dir=$gitDir", "--work-tree=$(Get-HubPath '')")
if (-not (Test-Path -LiteralPath $gitDir)) {
    & $git init --quiet --bare $gitDir 2>&1 | Out-Null
    & $git @hubArgs config core.autocrlf false 2>&1 | Out-Null
}
$exclude = @('/projects/', '/workspaces/', '/envs/', '/runs/', '/state/', '*.tmp', '.verify.log', '/hub/dashboard/*.bak')
Write-Text (Join-Path $gitDir 'info\exclude') (($exclude -join "`n") + "`n")
& $git @hubArgs add --all 2>&1 | Out-Null
& $git @hubArgs diff --cached --quiet 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    $msg = Join-Path $env:TEMP "agenthub-backup-msg.txt"
    Write-Text $msg "Sicherung $(Get-Date -Format 'dd.MM.yyyy HH:mm')`n"
    & $git @hubArgs -c user.name=AgentHub -c user.email=agenthub@localhost commit --quiet -F $msg 2>&1 | Out-Null
    Remove-Item -LiteralPath $msg -Force -ErrorAction SilentlyContinue
}
$out = & $git @hubArgs push --force --quiet $url 'HEAD:refs/heads/hub' 2>&1
if ($LASTEXITCODE -eq 0) { $done += 'hub' } else { $problems += "hub: $((@($out) -join ' ').Trim())" }

$ok = $problems.Count -eq 0
$message = if ($ok) { "$($done.Count) Teile gesichert" } else { "Fehler bei $($problems.Count) Teil(en)" }
Write-Json $statusFile ([ordered]@{ finished = (Get-Now); ok = $ok; message = $message; saved = $done; problems = $problems })
Add-HubLog "Sicherung: $message$(if (-not $ok) { ' – ' + ($problems -join ' | ') })"
Write-Host "Sicherung: $message"
foreach ($p in $problems) { Write-Host "  $p" }
if (-not $ok) { Send-HubNachricht 'Agent Hub: Sicherung fehlgeschlagen' (($problems | Select-Object -First 2) -join '; ') }
exit $(if ($ok) { 0 } else { 1 })
