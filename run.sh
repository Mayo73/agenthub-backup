#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
echo "Running headless Godot tests..."
godot --headless --path . --script res://tests/run_tests.gd
