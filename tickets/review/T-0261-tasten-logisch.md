---
id: T-0261
title: Tasten auch mit logischem Tastencode belegen
project: zellenphase
priority: 4
---
## Ziel
Fernsteuerungen wie Computer Use schicken Tasten ohne physischen Tastencode. Bisher belegt `Controls` jede Taste nur mit `physical_keycode`, deshalb wirken D (Schwimmen) und Esc (Pause) dann nicht (Spieltest `tasten`). Jede Taste bekommt zusätzlich ein zweites Ereignis mit logischem Tastencode (`keycode`).

## Dateien
- `scripts/controls.gd`
- `tests/test_controls.gd`

## Akzeptanzkriterien
- In `scripts/controls.gd` eine neue statische Funktion direkt über `_add`:
```gdscript
## Hängt für eine Taste zwei Ereignisse an: nach Lage (physical_keycode, passt auf QWERTZ)
## und nach logischem Tastencode (keycode), wie ihn Fernsteuerungen schicken.
static func _add_key(action: String, key: int) -> void:
	var physical := InputEventKey.new()
	physical.physical_keycode = key
	InputMap.action_add_event(action, physical)
	var logical := InputEventKey.new()
	logical.keycode = key
	InputMap.action_add_event(action, logical)
```
- In `_add(...)` die Schleife über die Tasten so ändern, dass sie für jede Taste nur noch `_add_key(action, key)` aufruft. Mausknöpfe bleiben unverändert.
- Gibt es in `scripts/controls.gd` weitere Stellen, die Tasten-Ereignisse anlegen oder lesen (z. B. eine Funktion, die die erste Taste liefert), dort nur Ereignisse mit `physical_keycode != 0` als „erste Taste“ zählen.
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_controls.gd` anhängen:
- `test_logischer_tastencode`: `Controls.setup()`; über `InputMap.action_get_events("pause")` zählen: genau ein `InputEventKey` mit `keycode == KEY_ESCAPE` und `physical_keycode == 0`, genau eines mit `physical_keycode == KEY_ESCAPE`
- `test_logische_taste_loest_aus`: `Controls.setup()`; `var e := InputEventKey.new()`; `e.keycode = KEY_D`; `e.pressed = true` → `e.is_action("rechts")` ist wahr; dasselbe mit `KEY_ESCAPE` und `"pause"`
- `test_maus_unveraendert`: `Controls.setup()`; `"schwimmen"` hat genau ein Ereignis, und es ist ein `InputEventMouseButton`
