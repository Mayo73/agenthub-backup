@echo off
rem Startet Worker und Dashboard im Hintergrund und oeffnet das Dashboard.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0hub\launch.ps1" -Open
