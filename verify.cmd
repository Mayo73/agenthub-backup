@echo off
rem Automatische Pruefung des Projekts. Der Worker fuehrt sie nach jedem Agentenlauf aus,
rem du kannst sie auch selbst starten. Exit-Code 0 = alles in Ordnung.
rem Bestanden ist nur ein Lauf, der am Ende "ERGEBNIS: ... ok, 0 fehlgeschlagen" meldet.
setlocal
cd /d "%~dp0"

rem Godot-Konsolenversion finden (der Worker setzt GODOT_BIN, sonst Suche im WinGet-Ordner)
if not defined GODOT_BIN for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*") do for %%E in ("%%D\Godot_*_console.exe") do set "GODOT_BIN=%%~E"
if not defined GODOT_BIN set "GODOT_BIN=godot"

rem Protokoll im Projektordner: Jede Arbeitskopie hat ihr eigenes, parallele Laeufe stoeren sich nicht.
set "LOG=%~dp0.verify.log"

echo == Import (aktualisiert den Klassen-Cache) == > "%LOG%" || goto :logfail
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
findstr /R /C:"^ERGEBNIS: [0-9]* ok, 0 fehlgeschlagen" "%LOG%" >nul
if errorlevel 1 (
  echo.
  echo == Kein vollstaendiges Testergebnis: Der Testlauf ist nicht bis zum Ende gekommen ==
  set "RC=1"
)
exit /b %RC%

:logfail
echo Die Protokolldatei "%LOG%" ist nicht beschreibbar.
exit /b 1
