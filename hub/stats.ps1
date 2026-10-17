# Kennzahlen der Agent-Läufe, je Modell: Dauer, Versuche, Erfolgsquote, Ergebnis des Reviews.
# Grundlage für Ticketgröße und Modellwahl (siehe CLAUDE.md, "Gute Tickets" und "Modellvergleich").
#   powershell -NoProfile -ExecutionPolicy Bypass -File hub\stats.ps1 [-Days 7]
param([int]$Days = 0)

. (Join-Path $PSScriptRoot 'common.ps1')

# Review-Vermerk am Ende des Tickets: "Review (Datum): gemergt[, nachgebessert: …]" bzw. "abgelehnt" / "aufgeteilt".
# Ältere Vermerke sprechen von "Korrigiert", "Korrektur" oder "selbst aufgelöst"; das zählt auch als Nachbesserung.
$verdict = @{}
foreach ($ticket in @(Get-Tickets 'done')) {
    $note = [regex]::Matches($ticket.Body, '(?m)^Review \([^)]*\):\s*(.*)$') | Select-Object -Last 1
    if (-not $note) { continue }
    $text = $note.Groups[1].Value
    if ($text -match '^abgelehnt') { $verdict[$ticket.Id] = 'abgelehnt' }
    elseif ($text -match '^aufgeteilt') { $verdict[$ticket.Id] = 'aufgeteilt' }
    elseif ($text -match 'nachgebessert|korrigiert|korrektur|selbst aufgelöst|selbst behoben') { $verdict[$ticket.Id] = 'nachgebessert' }
    else { $verdict[$ticket.Id] = 'gemergt' }
}

$since = if ($Days -gt 0) { (Get-Date).AddDays(-$Days) } else { [datetime]::MinValue }
$runs = @(Get-ChildItem (Get-HubPath 'runs') -Directory | Where-Object { $_.Name -match '^T-\d+$' } | ForEach-Object {
    $st = Read-Json (Join-Path $_.FullName 'status.json')
    if (-not $st -or -not $st.started -or -not $st.finished) { return }
    $started = [datetime]::Parse($st.started)
    if ($started -lt $since) { return }
    $attempts = @($st.attempts)
    [pscustomobject]@{
        Id = $st.id; Model = $st.model; State = $st.state; Started = $started
        Minutes = ([datetime]::Parse($st.finished) - $started).TotalMinutes
        Attempts = $attempts.Count
        TimedOut = @($attempts | Where-Object { $_.timedOut }).Count -gt 0
        Verdict = $verdict[$st.id]
    }
})
if ($runs.Count -eq 0) { Write-Host 'Keine abgeschlossenen Läufe.'; exit 0 }

$rows = foreach ($group in ($runs | Group-Object Model)) {
    $r = @($group.Group)
    $passed = @($r | Where-Object { $_.State -eq 'passed' })
    $reviewed = @($r | Where-Object { $_.Verdict })
    $pct = { param($n, $total) if ($total -gt 0) { '{0:N0} %' -f (100 * $n / $total) } else { '–' } }
    [pscustomobject]@{
        Modell             = $group.Name
        Tickets            = $r.Count
        Bestanden          = & $pct $passed.Count $r.Count
        'Im 1. Versuch'    = & $pct @($passed | Where-Object { $_.Attempts -eq 1 }).Count $r.Count
        'Ø min'            = '{0:N1}' -f ($r | Measure-Object Minutes -Average).Average
        'Max min'          = '{0:N1}' -f ($r | Measure-Object Minutes -Maximum).Maximum
        Zeitlimit          = @($r | Where-Object { $_.TimedOut }).Count
        'Review: sauber'   = & $pct @($reviewed | Where-Object { $_.Verdict -eq 'gemergt' }).Count $reviewed.Count
        Nachgebessert      = @($reviewed | Where-Object { $_.Verdict -eq 'nachgebessert' }).Count
        Abgelehnt          = @($reviewed | Where-Object { $_.Verdict -eq 'abgelehnt' }).Count
    }
}
$rows | Format-Table -AutoSize | Out-String -Width 200 | Write-Host

# Auslastung: Anteil der letzten 24 Stunden, in dem der Worker an Tickets gearbeitet hat.
$dayAgo = (Get-Date).AddHours(-24)
$busy = ($runs | Where-Object { $_.Started -ge $dayAgo } | Measure-Object Minutes -Sum).Sum
Write-Host ('Auslastung der letzten 24 Stunden: {0:N0} % ({1:N0} min Arbeit)' -f (100 * $busy / 1440), $busy)
Write-Host "Review: sauber = ohne Nachbesserung gemergt, bezogen auf die schon reviewten Tickets."
