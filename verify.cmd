@echo off
rem Automatische Pruefung der React-Native-App in app\. Der Worker fuehrt sie nach jedem Agentenlauf aus,
rem du kannst sie auch selbst starten. Exit-Code 0 = alles in Ordnung.
rem Bestanden ist nur ein Lauf, der am Ende "ERGEBNIS: ... ok, 0 fehlgeschlagen" meldet.
setlocal
cd /d "%~dp0app"

rem Node.js finden (PATH, sonst WinGet-Ordner)
where node >nul 2>nul
if errorlevel 1 for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\OpenJS.NodeJS.LTS_*") do for /d %%E in ("%%D\node-v*-win-x64") do set "PATH=%%~E;%PATH%"
where node >nul 2>nul
if errorlevel 1 (
  echo Node.js nicht gefunden.
  exit /b 1
)

rem Pakete liegen gemeinsam unter AgentHub\envs\sparring (Arbeitskopie und Worker-Worktree)
if not exist node_modules mklink /J node_modules "%~dp0..\..\envs\sparring\node_modules" >nul

set "LOG=%~dp0.verify.log"
echo == Typpruefung == > "%LOG%" || goto :logfail
call node_modules\.bin\tsc.cmd --noEmit >> "%LOG%" 2>&1
set "TSC=%ERRORLEVEL%"
echo == Tests == >> "%LOG%"
if exist "%~dp0.jest.json" del "%~dp0.jest.json"
call node_modules\.bin\jest.cmd --ci --silent --json --outputFile="%~dp0.jest.json" >> "%LOG%" 2>&1
echo == Auswertung == >> "%LOG%"
node "%~dp0verify-ergebnis.js" "%~dp0.jest.json" %TSC% >> "%LOG%" 2>&1
set "RC=%ERRORLEVEL%"
type "%LOG%"
exit /b %RC%

:logfail
echo Die Protokolldatei "%LOG%" ist nicht beschreibbar.
exit /b 1
