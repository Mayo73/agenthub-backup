@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

rem Find Godot console exe via WinGet pattern
set GODOT_BIN=""
for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*") do (
    for %%E in ("%%D\Godot_*_console.exe") do set "GODOT_BIN=%%~E"
)

rem Fallback to PATH
if "!GODOT_BIN!"=="" set GODOT_BIN=godot

echo Godot: !GODOT_BIN!
call !GODOT_BIN! --headless --path . --import 2>&1 | findstr /V "^$" || (echo Import failed; exit /b 1)
call !GODOT_BIN! --headless --path . --script res://tests/run_tests.gd 2>&1

exit /b %ERRORLEVEL%
