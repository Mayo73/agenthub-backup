@echo off
cd /d "%~dp0"
godot --headless --path . --script res://tests/run_tests.gd
