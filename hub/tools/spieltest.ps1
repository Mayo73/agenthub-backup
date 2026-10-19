# Spieltests eines Godot-Projekts mit simulierter Eingabe (Tests: projects\<projekt>\playtests\<name>.gd,
# Grundlage playtests\playtest.gd aus hub\tools\vorlagen, Ablauf: hub\tools\spieltest_runner.gd).
#   spieltest.ps1 -Projekt drift                       alle Tests, unsichtbar und schneller als Echtzeit
#   spieltest.ps1 -Projekt drift -Test rennen,pause    nur diese
#   spieltest.ps1 -Projekt drift -Liste                vorhandene Tests mit Beschreibung
#   spieltest.ps1 -Projekt drift -Test drift -Film -Ziel lastenhefte\punkte\P-0007
#       als Film (Fenster minimiert, Echtzeit-Bilder): Standbilder (shot) und Bildstreifen (film) ins Ziel,
#       dazu je Test ein Tonbericht <test>-ton.txt
# Ergebnis: Zeilen "SPIELTEST-OK/-FEHLGESCHLAGEN: …" und am Ende "SPIELTESTS: <n> ok, <m> fehlgeschlagen".
param(
    [Parameter(Mandatory = $true)][string]$Projekt,
    [string]$Test = '',
    [switch]$Liste,
    [switch]$Film,
    [string]$Ziel = '',
    [int]$Fps = 30,
    [int]$Streifenbilder = 6,
    [string]$Pfad = ''
)

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'common.ps1')
. (Join-Path $PSScriptRoot 'ton.ps1') -NurLaden
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch { }
$cfg = Get-HubConfig
$project = $cfg.projects.$Projekt
if (-not $Pfad) { $Pfad = $project.path }
if (-not $project -or -not (Test-Path -LiteralPath (Join-Path $Pfad 'project.godot'))) {
    Write-Host "SPIELTESTS: FEHLER $Projekt ist kein Godot-Projekt aus config.json."; exit 1
}
if (-not (Test-Path -LiteralPath (Join-Path $Pfad 'playtests\playtest.gd'))) {
    Write-Host "SPIELTESTS: FEHLER $Projekt hat noch keine Spieltests (playtests\playtest.gd fehlt, Vorlage: hub\tools\vorlagen)."; exit 1
}
$godot = Resolve-GodotBin $cfg
$runner = (Join-Path $PSScriptRoot 'spieltest_runner.gd') -replace '\\', '/'
$tmp = Join-Path ([IO.Path]::GetTempPath()) ("agenthub-spieltest-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

# Klassen-Cache auffrischen, damit neue Spieltests (class_name) bekannt sind.
& $godot --headless --path $Pfad --import *> (Join-Path $tmp 'import.log')

$userArgs = @()
if ($Test) { $userArgs += "--test=$Test" }
if ($Liste) { $userArgs += '--liste' }
$log = Join-Path $tmp 'spieltest.log'
if ($Film) {
    if (-not $Ziel) { Write-Host 'SPIELTESTS: FEHLER -Film braucht -Ziel.'; exit 1 }
    if (-not [IO.Path]::IsPathRooted($Ziel)) { $Ziel = Get-HubPath $Ziel }
    New-Item -ItemType Directory -Force -Path $Ziel | Out-Null
    $godotArgs = @('--path', "`"$Pfad`"", '--write-movie', "`"$tmp\frame.png`"", '--fixed-fps', "$Fps", '--resolution', (Get-GodotAufloesung $Pfad), '--script', "`"$runner`"")
    $style = 'Minimized'
} else {
    $godotArgs = @('--headless', '--path', "`"$Pfad`"", '--fixed-fps', '60', '--script', "`"$runner`"")
    $style = 'Hidden'
}
if ($userArgs.Count -gt 0) { $godotArgs += @('--') + $userArgs }
$proc = Start-Process -FilePath $godot -ArgumentList $godotArgs -WorkingDirectory $Pfad -WindowStyle $style `
    -RedirectStandardOutput $log -RedirectStandardError "$log.err" -PassThru
if (-not $proc.WaitForExit(45 * 60 * 1000)) {
    & taskkill.exe /PID $proc.Id /T /F | Out-Null
    Write-Host 'SPIELTESTS: FEHLER Zeitlimit von 45 Minuten überschritten.'
}

$output = @(Get-Content -LiteralPath $log -Encoding UTF8 -ErrorAction SilentlyContinue)
$errors = @(Get-Content -LiteralPath "$log.err" -Encoding UTF8 -ErrorAction SilentlyContinue | Where-Object { $_ -match 'SCRIPT ERROR|Parse Error|ERROR:' } | Select-Object -Unique -First 15)
foreach ($line in $output) {
    if ($line -match '^SPIELTEST-(NAME|OK|FEHLGESCHLAGEN|FEHLER|WERT):' -or $line -match '^SPIELTESTS:') { Write-Host $line }
}
foreach ($line in $errors) { Write-Host "GODOT: $line" }

if ($Film) {
    $frames = @(Get-ChildItem -LiteralPath $tmp -Filter 'frame*.png' | Sort-Object Name)
    # Bildnummern aus Godot (frames_drawn) auf Bilddateien abbilden: Am Schluss gehört die letzte Datei
    # zur zuletzt gemeldeten Nummer, daraus ergibt sich der Versatz.
    $offset = 0
    $last = $output | Where-Object { $_ -match '^SPIELTEST-SCHLUSS: \d+' } | Select-Object -Last 1
    if ("$last" -match '^SPIELTEST-SCHLUSS: (\d+)') { $offset = ($frames.Count - 1) - [int]$Matches[1] }
    $frameAt = { param([int]$n) if ($frames.Count -eq 0) { return $null }; $frames[[math]::Max(0, [math]::Min($frames.Count - 1, $n + $offset))] }
    $current = 'test'; $segments = [ordered]@{}; $werte = @{}
    foreach ($line in $output) {
        if ($line -match '^SPIELTEST-START: (\S+) (\d+)') { $current = $Matches[1]; $segments[$current] = @{ Von = [int]$Matches[2] + $offset; Bis = -1 }; $werte[$current] = @{} }
        elseif ($line -match '^SPIELTEST-ENDE: (\S+) (\d+)') { if ($segments.Contains($Matches[1])) { $segments[$Matches[1]].Bis = [int]$Matches[2] + $offset } }
        elseif ($line -match '^SPIELTEST-BILD: (\S+) (\d+)') {
            $f = & $frameAt ([int]$Matches[2])
            if ($f) { $dest = Join-Path $Ziel "$current-$($Matches[1]).png"; Copy-Item -LiteralPath $f.FullName -Destination $dest -Force; Write-Host "BILD: $dest" }
        }
        elseif ($line -match '^SPIELTEST-FILM: (\S+) (\d+) (\d+)') {
            # Die letzten zwei Bilder auslassen: Danach kann schon die nächste Szene geladen sein.
            $von = [int]$Matches[2]; $bis = [math]::Max([int]$Matches[2], [int]$Matches[3] - 2); $teile = @()
            for ($i = 0; $i -lt $Streifenbilder; $i++) {
                $f = & $frameAt ([int]($von + ($bis - $von) * $i / [math]::Max(1, $Streifenbilder - 1)))
                if ($f) { $teile += $f.FullName }
            }
            if ($teile.Count -gt 0) {
                $dest = Join-Path $Ziel "$current-$($Matches[1])-streifen.png"
                $res = & $godot --headless --script ((Join-Path $PSScriptRoot 'streifen.gd') -replace '\\', '/') -- $dest 3 640 @teile 2>&1 | Select-String 'STREIFEN'
                Write-Host "STREIFEN: $dest ($res)"
            }
        }
        elseif ($line -match '^SPIELTEST-WERT: (\S+) (\S+) (\d+)') {
            if (-not $werte.Contains($current)) { $werte[$current] = @{} }
            if (-not $werte[$current].Contains($Matches[1])) { $werte[$current][$Matches[1]] = New-Object System.Collections.ArrayList }
            $zahl = 0.0
            if ([double]::TryParse($Matches[2], [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$zahl)) {
                [void]$werte[$current][$Matches[1]].Add(@{ Zeit = ([int]$Matches[3] + $offset) / $Fps; Wert = $zahl })
            }
        }
    }
    $wav = Join-Path $tmp 'frame.wav'
    if (Test-Path -LiteralPath $wav) {
        foreach ($name in $segments.Keys) {
            $seg = $segments[$name]
            $bis = if ($seg.Bis -gt $seg.Von) { $seg.Bis / $Fps } else { -1 }
            try {
                $ergebnis = Get-TonAnalyse $wav ($seg.Von / $Fps) $bis 1
                $bericht = Format-TonBericht $ergebnis $werte[$name]
                $dest = Join-Path $Ziel "$name-ton.txt"
                Write-Text $dest ((@("Tonbericht Spieltest $Projekt/$name (Zeit ab Programmstart)") + $bericht) -join "`r`n")
                Write-Host "TON: $dest"
            } catch { Write-Host "TON: FEHLER $($_.Exception.Message)" }
        }
    } else { Write-Host 'TON: keine Tonaufnahme gefunden.' }
}
Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
if ($Liste) { exit 0 }
$summary = "$($output | Where-Object { $_ -like 'SPIELTESTS:*' } | Select-Object -Last 1)"
if ($summary -notmatch '^SPIELTESTS: (\d+) ok, (\d+) fehlgeschlagen') {
    Write-Host 'SPIELTESTS: FEHLER Kein Ergebnis, der Lauf ist abgebrochen (siehe GODOT-Zeilen).'; exit 1
}
# Ein Skriptfehler bricht nur die betroffene Funktion ab; der Test kann danach fälschlich "ok" melden.
if (@($errors | Where-Object { $_ -match 'SCRIPT ERROR|Parse Error' }).Count -gt 0) {
    Write-Host 'SPIELTESTS: FEHLER Skriptfehler während der Spieltests (siehe GODOT-Zeilen); die Ergebnisse oben sind nicht verlässlich.'; exit 1
}
if ([int]$Matches[2] -gt 0) { exit 1 }
exit 0
