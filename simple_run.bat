@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

set GODOT_BIN=""
for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*") do (
    for %%E in ("%%D\Godot_*_console.exe") do set "GODOT_BIN=%%~E"
)

echo Looking for Godot...
if "!GODOT_BIN!"=="" (
    echo Using 'godot' from PATH
    set GODOT_BIN=godot
)

echo Running: !GODOT_BIN! --headless --path . --script res://tests/run_tests.gd
"!GODOT_BIN!" --headless --path . --import
"!GODOT_BIN!" --headless --path . --script res://tests/run_tests.gd
