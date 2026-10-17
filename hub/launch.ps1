# Startet Worker und Dashboard-Server unsichtbar, falls sie nicht schon laufen.
#   -Open:     danach das Dashboard im Browser öffnen
#   -Watchdog: Aufruf durch die Windows-Aufgabe "AgentHub-Waechter" (alle 15 Minuten).
#              Startet nichts, wenn der Hub mit stop-hub.cmd bewusst beendet wurde.
param([switch]$Open, [switch]$Watchdog)

. (Join-Path $PSScriptRoot 'common.ps1')
New-Item -ItemType Directory -Force -Path (Get-HubPath 'state') | Out-Null

$stopFlag = Get-HubPath 'state\stopped'
if ($Watchdog) {
    if (Test-Path -LiteralPath $stopFlag) { exit 0 }
} else {
    Remove-Item -LiteralPath $stopFlag -Force -ErrorAction SilentlyContinue
}

foreach ($name in @('worker', 'server')) {
    $running = Read-Text (Get-HubPath "state\$name.pid")
    if ($running -and (Get-ProcessAlive $running.Trim())) {
        # Der Worker meldet sich mindestens alle 30 Sekunden. Ist er seit 10 Minuten still, hängt er.
        $state = $null
        if ($Watchdog -and $name -eq 'worker') { $state = Read-Json (Get-HubPath 'state\worker.json') }
        $beat = $null
        if ($state -and "$($state.pid)" -eq $running.Trim()) { try { $beat = [datetime]::Parse("$($state.heartbeat)") } catch { } }
        if (-not $beat -or ((Get-Date) - $beat).TotalMinutes -lt 10) {
            Write-Host "$name läuft bereits (PID $($running.Trim()))"
            continue
        }
        & taskkill.exe /PID $running.Trim() /T /F | Out-Null
        Add-HubLog "Wächter: Worker hing (letzter Herzschlag $($beat.ToString('HH:mm'))) und wurde beendet"
    }
    $script = Join-Path $PSScriptRoot "$name.ps1"
    $proc = Start-Process -FilePath 'powershell.exe' -WindowStyle Hidden -PassThru `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$script`""
    Write-Text (Get-HubPath "state\$name.pid") "$($proc.Id)"
    Write-Host "$name gestartet (PID $($proc.Id))"
    if ($Watchdog) { Add-HubLog "Wächter: $name lief nicht und wurde neu gestartet (PID $($proc.Id))" }
}

# Nächtliche Sicherung nach GitHub, sobald die letzte älter als 23 Stunden ist (siehe backup.ps1).
if ($Watchdog -and "$((Get-HubConfig).backup.url)") {
    Start-Process -FilePath 'powershell.exe' -WindowStyle Hidden `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$(Join-Path $PSScriptRoot 'backup.ps1')`" -WennFaellig"
}

if ($Open) {
    Start-Sleep -Seconds 2
    Start-Process "http://localhost:$((Get-HubConfig).port)/"
}
