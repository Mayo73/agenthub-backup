#!/bin/bash
set -e

GODOT_PATHS=(
  "/mnt/c/Program Files/Godot*"
  "/mnt/c/godot*"
)

GODOT_BIN=""
for path in "${GODOT_PATHS[@]}"; do
    for f in $path; do
        if [ -f "$f" ]; then
            GODOT_BIN="$f"
            break 2
        fi
    done
done

if [ -z "$GODOT_BIN" ]; then
    GODOT_BIN="godot"
fi

echo "Using Godot: $GODOT_BIN"

# Import
"$GODOT_BIN" --headless --path . --import

# Run tests
"$GODOT_BIN" --headless --path . --script res://tests/run_tests.gd
EXIT_CODE=$?

exit $EXIT_CODE
