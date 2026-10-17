---
id: T-0017
title: Taste „pause“ (Esc)
project: drift
priority: 3
---
## Ziel
Für das Pausemenü braucht es eine eigene Aktion `pause`: Esc auf der Tastatur, die Back-/Select-Taste am Gamepad.

## Dateien
- `scripts/controls.gd`
- `tests/test_controls.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `"pause"` hinten an `ACTIONS` anhängen.
- In `setup()` als letzte Zeile: `_add("pause", [KEY_ESCAPE], [JOY_BUTTON_BACK], [])`
- Keine anderen Dateien ändern.

## Tests
In `tests/test_controls.gd` neue Methode `test_pause_taste` anhängen: nach `Controls.setup()` ist `InputMap.has_action("pause")` wahr und `"pause" in Controls.ACTIONS` wahr.

Review (16.10.2026): gemergt.
