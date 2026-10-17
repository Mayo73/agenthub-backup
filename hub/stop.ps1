# Beendet Worker und Dashboard-Server samt laufendem Agent.
# Ein Ticket, das gerade in Arbeit war, kommt beim nächsten Start automatisch zurück nach "Offen".
# Bis zum nächsten start-hub.cmd (oder Review) startet der Wächter den Hub nicht neu.

. (Join-Path $PSScriptRoot 'common.ps1')
Write-Text (Get-HubPath 'state\stopped') (Get-Now)

foreach ($name in @('worker', 'server')) {
    $pidFile = Get-HubPath "state\$name.pid"
    $running = Read-Text $pidFile
    if ($running -and (Get-ProcessAlive $running.Trim())) {
        & taskkill.exe /PID $running.Trim() /T /F | Out-Null
        Write-Host "$name beendet (PID $($running.Trim()))"
    } else {
        Write-Host "$name lief nicht"
    }
    Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
}
Add-HubLog 'Hub gestoppt'
