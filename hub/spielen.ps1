# Startet ein Projekt zum Ausprobieren (neuester geprüfter Stand in projects\<projekt>),
# vor allem für ChatGPT per Computer Use (siehe lastenhefte\AGENTS.md).
#   hub\spielen.cmd drift
#   hub\spielen.cmd zellenphase --szene=jagd    (alles nach dem Projektnamen geht an das Spiel)
# Godot-Projekte startet es mit der Fensterversion von Godot; andere Projekte brauchen ein start.cmd im Projektordner.
param([Parameter(Position = 0)][string]$Projekt, [Parameter(ValueFromRemainingArguments = $true)][string[]]$Rest)

. (Join-Path $PSScriptRoot 'common.ps1')
$cfg = Get-HubConfig
$names = @($cfg.projects.PSObject.Properties.Name)
if (-not $Projekt -or $names -notcontains $Projekt) {
    Write-Host "Aufruf: spielen.cmd <projekt> [Angaben für das Spiel]. Projekte: $($names -join ', ')"
    exit 1
}
$path = $cfg.projects.$Projekt.path
$userArgs = @($Rest | Where-Object { $_ -ne $null -and $_ -ne '' })

$start = Join-Path $path 'start.cmd'
if (Test-Path -LiteralPath $start) {
    Start-Process -FilePath $env:ComSpec -ArgumentList (@('/c', "`"$start`"") + $userArgs) -WorkingDirectory $path
    Write-Host "$Projekt gestartet (start.cmd)."
    exit 0
}
if (-not (Test-Path -LiteralPath (Join-Path $path 'project.godot'))) {
    Write-Host "$Projekt hat weder project.godot noch start.cmd und lässt sich nicht starten."
    exit 1
}

# Fensterversion statt Konsolenversion, damit kein zusätzliches Konsolenfenster aufgeht.
$godot = Resolve-GodotBin $cfg
$windowed = $godot -replace '_console\.exe$', '.exe'
if ($windowed -ne $godot -and (Test-Path -LiteralPath $windowed)) { $godot = $windowed }
# Angaben für das Spiel stehen bei Godot hinter "--" (OS.get_cmdline_user_args).
if ($userArgs.Count -gt 0 -and $userArgs[0] -ne '--') { $userArgs = @('--') + $userArgs }
$proc = Start-Process -FilePath $godot -ArgumentList (@('--path', "`"$path`"") + $userArgs) -WorkingDirectory $path -PassThru
Write-Host "$Projekt gestartet (PID $($proc.Id))."
