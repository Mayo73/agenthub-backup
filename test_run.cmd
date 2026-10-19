@echo off
setlocal
cd /d "%~dp0"
set GODOT_BIN=C:\Program Files\Godot\godot.exe
"%GODOT_BIN%" --headless --path . --script res://tests/run_tests.gd
