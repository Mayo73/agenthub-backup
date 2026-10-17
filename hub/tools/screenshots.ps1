# Screenshots eines Godot-Projekts, z. B. als Material für ChatGPT (Punkte zum Ansehen).
# Nutzt den Movie-Maker-Modus von Godot: Das Spiel läuft kurz mit fester Bildrate in einem Fenster
# und schreibt jedes Bild als PNG; davon bleiben einige gleichmäßig verteilte übrig.
#   powershell -NoProfile -ExecutionPolicy Bypass -File hub\tools\screenshots.ps1 -Projekt drift `
#       -Ziel lastenhefte\punkte\P-0003 [-Szene res://scenes/main.tscn] [-Sekunden 6] [-Bilder 4] [-Name rennen] [-Spiel '--szene=jagd']
# Ohne -Szene startet die Hauptszene. Ausgabe: je Bild eine Zeile "SCREENSHOT: <pfad>", am Ende "SCREENSHOTS: <n> ok".
param(
    [Parameter(Mandatory = $true)][string]$Projekt,
    [Parameter(Mandatory = $true)][string]$Ziel,
    [string]$Szene = '',
    [double]$Sekunden = 5,
    [int]$Bilder = 4,
    [string]$Name = 'bild',
    [int]$Fps = 30,
    [string[]]$Spiel = @()
)

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'common.ps1')
$cfg = Get-HubConfig
$project = $cfg.projects.$Projekt
if (-not $project -or -not (Test-Path -LiteralPath (Join-Path $project.path 'project.godot'))) {
    Write-Host "SCREENSHOTS: FEHLER $Projekt ist kein Godot-Projekt aus config.json."
    exit 1
}
if (-not [IO.Path]::IsPathRooted($Ziel)) { $Ziel = Get-HubPath $Ziel }
# Mehrere Angaben fürs Spiel mit Komma getrennt (über -File kommt nur ein String an).
$Spiel = @($Spiel | ForEach-Object { "$_" -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
New-Item -ItemType Directory -Force -Path $Ziel | Out-Null

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("agenthub-shots-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$frames = [math]::Max(2, [int][math]::Ceiling($Sekunden * $Fps))
$godotArgs = @('--path', "`"$($project.path)`"")
if ($Szene) { $godotArgs += $Szene }
$godotArgs += @('--write-movie', "`"$tmp\frame.png`"", '--fixed-fps', "$Fps", '--quit-after', "$frames", '--resolution', '1280x720')
if ($Spiel.Count -gt 0) { $godotArgs += @('--') + $Spiel }

$log = Join-Path $tmp 'godot.log'
$proc = Start-Process -FilePath (Resolve-GodotBin $cfg) -ArgumentList $godotArgs -WorkingDirectory $project.path `
    -WindowStyle Minimized -RedirectStandardOutput $log -RedirectStandardError "$log.err" -PassThru
# Movie Maker rechnet nicht in Echtzeit; großzügiges Zeitlimit.
if (-not $proc.WaitForExit([int](60000 + $Sekunden * 20000))) {
    & taskkill.exe /PID $proc.Id /T /F | Out-Null
    Write-Host "SCREENSHOTS: FEHLER Zeitlimit überschritten."
}

$all = @(Get-ChildItem -LiteralPath $tmp -Filter 'frame*.png' | Sort-Object Name)
if ($all.Count -eq 0) {
    Write-Host "SCREENSHOTS: FEHLER Godot hat keine Bilder geschrieben. Ausgabe:"
    Get-Content -LiteralPath $log, "$log.err" -ErrorAction SilentlyContinue | Select-Object -Last 15 | ForEach-Object { Write-Host "  $_" }
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}
# Gleichmäßig verteilt, das letzte Bild immer dabei (Bild 1 = 1/n des Ablaufs).
$count = [math]::Min($Bilder, $all.Count)
for ($i = 1; $i -le $count; $i++) {
    $index = [int][math]::Round($i * ($all.Count - 1) / $count)
    $dest = Join-Path $Ziel ("{0}-{1}.png" -f $Name, $i)
    Copy-Item -LiteralPath $all[$index].FullName -Destination $dest -Force
    Write-Host "SCREENSHOT: $dest"
}
Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "SCREENSHOTS: $count ok"
