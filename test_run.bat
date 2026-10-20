@echo off
setlocal
for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*") do for %%E in ("%%D\Godot_*_console.exe") do set "GODOT_BIN=%%~E"
if not defined GODOT_BIN set "GODOT_BIN=godot"
echo Godot-Binärdatei: %GODOT_BIN%
"%GODOT_BIN%" --headless --path . --script res://tests/run_tests.gd
