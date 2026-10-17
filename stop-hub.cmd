@echo off
rem Beendet Worker und Dashboard (ein laufendes Ticket kommt beim naechsten Start zurueck nach "Offen").
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0hub\stop.ps1"
pause
