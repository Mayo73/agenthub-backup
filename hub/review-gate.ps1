# Entscheidet, ob die stündliche Review-Aufgabe jetzt einen Review-Durchgang braucht
# (Regeln: Get-ReviewNeed in common.ps1, Grenzen: "reviewGate" in config.json).
#   powershell -NoProfile -ExecutionPolicy Bypass -File hub\review-gate.ps1
#       -> "REVIEW: ja" oder "REVIEW: nein" mit Gründen; bei ja wird state\review.lock angelegt
#   ... -Force    Review auf Wunsch des Nutzers: immer ja, mit Sperre
#   ... -Done     am Ende jedes Reviews: Sperre lösen, Zeitpunkt in state\last-review.json merken
#   ... -DryRun [-Now '16.10.2026 12:00']   nur anzeigen, nichts anlegen (zum Testen)
param([switch]$Force, [switch]$Done, [switch]$DryRun, [string]$Now)

. (Join-Path $PSScriptRoot 'common.ps1')
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch { }
$lockFile = Get-HubPath 'state\review.lock'

if ($Done) {
    Remove-Item -LiteralPath $lockFile -Force -ErrorAction SilentlyContinue
    Write-Json (Get-HubPath 'state\last-review.json') ([ordered]@{ finished = (Get-Now) })
    Add-HubLog 'Review beendet'
    Write-Host 'Review als beendet vermerkt.'
    exit 0
}

$at = Get-Date
if ($Now) { $at = [datetime]::Parse($Now, [Globalization.CultureInfo]'de-DE') }
if ($Force) { $need = [pscustomobject]@{ Needed = $true; Reasons = @('Review auf Wunsch des Nutzers.') } }
else { $need = Get-ReviewNeed $at }

$verdict = if ($need.Needed) { 'ja' } else { 'nein' }
Write-Host "REVIEW: $verdict"
foreach ($reason in $need.Reasons) { Write-Host "- $reason" }
if ($DryRun) { exit 0 }

if ($need.Needed) { Write-Json $lockFile ([ordered]@{ started = (Get-Now); reasons = @($need.Reasons) }) }
Add-HubLog "Review-Prüfung: $verdict. $($need.Reasons -join ' ')"
