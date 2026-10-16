@echo off
setlocal EnableDelayedExpansion

rem Find Godot console executable from WinGet installation
set GODOT_BIN=godot
for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*") do (
    for %%E in ("%%D\Godot_*_console.exe") do set "GODOT_BIN=%%~E"
)

echo Found Godot: %GODOT_BIN%

rem Import project and run tests
call "%GODOT_BIN%" --headless --path . --import 2>&1 | findstr /V "^$" || goto :error
call "%GODOT_BIN%" --headless --path . --script res://tests/run_tests.gd

exit /b !ERRORLEVEL!

:error
echo Test run failed
exit /b 1
