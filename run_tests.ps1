# Run headless tests
cd $PSScriptRoot
godot --headless --path . --script res://tests/run_tests.gd
exit $LASTEXITCODE
