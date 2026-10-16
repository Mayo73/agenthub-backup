@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

rem Try to find Godot console executable
set GODOT_BIN=""
for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*") do (
    for %%E in ("%%D\Godot_*_console.exe") do set "GODOT_BIN=%%~E"
)

if "!GODOT_BIN!"=="" (
    rem Try standard godot
    where godot >nul 2>nul && set GODOT_BIN=godot
)

echo Godot binary: !GODOT_BIN!

if "!GODOT_BIN!"=="" (
    echo ERROR: Could not find Godot console executable
    exit /b 1
)

rem Run import and tests
"!GODOT_BIN!" --headless --path . --import > test_log.txt 2>&1
echo Exit code after import: %ERRORLEVEL%

"!GODOT_BIN!" --headless --path . --script res://tests/run_tests.gd >> test_log.txt 2>&1
echo Test exit code: %ERRORLEVEL%

type test_log.txt
exit /b %ERRORLEVEL%
