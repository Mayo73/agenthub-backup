@echo off
rem Automatische Pruefung des Projekts. Der Worker fuehrt sie nach jedem Agentenlauf aus,
rem du kannst sie auch selbst starten. Exit-Code 0 = alles in Ordnung.
setlocal
cd /d "%~dp0"

rem Godot-Konsolenversion finden (der Worker setzt GODOT_BIN, sonst Suche im WinGet-Ordner)
if not defined GODOT_BIN for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*") do for %%E in ("%%D\Godot_*_console.exe") do set "GODOT_BIN=%%~E"
if not defined GODOT_BIN set "GODOT_BIN=godot"

set "LOG=%TEMP%\testspiel-verify-%RANDOM%%RANDOM%.log"

echo == Import (aktualisiert den Klassen-Cache) == > "%LOG%"
"%GODOT_BIN%" --headless --path . --import >> "%LOG%" 2>&1
echo == Testlauf == >> "%LOG%"
"%GODOT_BIN%" --headless --path . --script res://tests/run_tests.gd >> "%LOG%" 2>&1
set "RC=%ERRORLEVEL%"
type "%LOG%"

findstr /C:"SCRIPT ERROR" /C:"Parse Error" /C:"Failed to load script" "%LOG%" >nul
if not errorlevel 1 (
  echo.
  echo == Skriptfehler in der Godot-Ausgabe gefunden ==
  set "RC=1"
)
del "%LOG%" >nul 2>&1
exit /b %RC%
