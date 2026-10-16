@echo off
cd /d "%~dp0"

set GODOT_BIN=""
for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*") do (
    for %%E in ("%%D\Godot_*_console.exe") do set "GODOT_BIN=%%~E"
)

if "!GODOT_BIN!"=="" set GODOT_BIN=godot

"!GODOT_BIN%" --headless --path . --import 2>&1 | findstr /V "^$" || echo Import done

"!GODOT_BIN%" --headless --path . --script res://tests/run_tests.gd 2>&1

exit /b %ERRORLEVEL%
