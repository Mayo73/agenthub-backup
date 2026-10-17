@echo off
rem Startet Drift ohne Godot-Editor. Aendert dabei keine Projektdateien.
rem Vorher wird kurz der Import-Cache aktualisiert, damit neue Skripte der Agents gefunden werden.
setlocal
set "PROJECT=%~dp0projects\drift"
for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*") do (
  for %%E in ("%%D\Godot_v*_win64.exe") do set "GODOT=%%~E"
  for %%E in ("%%D\Godot_v*_win64_console.exe") do set "GODOT_CONSOLE=%%~E"
)
if not defined GODOT (
  echo Godot wurde nicht gefunden.
  pause
  exit /b 1
)
"%GODOT_CONSOLE%" --headless --path "%PROJECT%" --import >nul 2>&1
start "" "%GODOT%" --path "%PROJECT%"
