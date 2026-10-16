#!/bin/bash
set -e
cd /d "$(dirname "$0")"
GODOT_BIN=$(find "%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*" -name "Godot_*_console.exe" 2>/dev/null | head -1)
if [ -z "$GODOT_BIN" ]; then
  GODOT_BIN="godot"
fi
echo "== Import =="
"$GODOT_BIN" --headless --path . --import
echo "== Testlauf =="
"$GODOT_BIN" --headless --path . --script res://tests/run_tests.gd
