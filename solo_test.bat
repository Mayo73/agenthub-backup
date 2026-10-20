@echo off
cd /d C:\Users\wiens\AgentHub\workspaces\sparring
echo Running Godot test...
godot --headless --path . --script res://tests/run_tests.gd
pause
