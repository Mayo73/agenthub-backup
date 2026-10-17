@echo off
rem Startet ein Projekt zum Ausprobieren, z. B. "spielen.cmd drift" oder "spielen.cmd zellenphase --szene=jagd".
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0spielen.ps1" %*
if errorlevel 1 pause
