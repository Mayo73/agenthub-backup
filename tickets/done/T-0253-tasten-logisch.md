---
id: T-0253
title: Tasten auch mit logischem Tastencode belegen
project: drift
priority: 1
---
## Ziel
Fernsteuerungen wie Computer Use schicken Tasten ohne physischen Tastencode. Bisher belegt `Controls` jede Taste nur mit `physical_keycode`, deshalb öffnet Esc dann das Pausemenü nicht (Spieltest `tasten`). Jede Taste bekommt zusätzlich ein zweites Ereignis mit logischem Tastencode (`keycode`).

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
- In `_add(...)` die Schleife `for key in keys:` (bisher drei Zeilen mit `key_event`) ersetzen durch:
```gdscript
	for key in keys:
		_add_key(action, key)
```
- In `rebind_key(action, keycode)` die letzten drei Zeilen (`var key_event := ...` bis `InputMap.action_add_event(action, key_event)`) ersetzen durch `_add_key(action, keycode)`.
- `key_for(action)` liefert weiterhin den ersten `physical_keycode`; dafür in der Schleife nur Ereignisse mit `event.physical_keycode != 0` zurückgeben:
```gdscript
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode != 0:
			return event.physical_keycode
```
- Sonst nichts ändern.

## Tests
- `tests/test_controls.gd`, `test_taste_aendern`: Weil jetzt je Taste zwei Ereignisse entstehen, die beiden Prüfungen anpassen (nicht löschen): `check_eq(key_count, 2, "zwei InputEventKey bei 'gas' (Lage und logisch)")` und `check(events.size() == 3, "drei Ereignisse insgesamt bei 'gas'")`.
- Am Ende von `tests/test_controls.gd` anhängen:
  - `test_logischer_tastencode`: `Controls.setup()`; über `InputMap.action_get_events("pause")` zählen, wie viele `InputEventKey` mit `keycode == KEY_ESCAPE` und `physical_keycode == 0` es gibt → genau 1; und wie viele mit `physical_keycode == KEY_ESCAPE` → genau 1.
  - `test_logisch_nach_aendern`: `Controls.setup()`; `Controls.rebind_key("gas", KEY_I)`; es gibt ein `InputEventKey` mit `keycode == KEY_I`; keines mit `keycode == KEY_W` oder `physical_keycode == KEY_W`; `Controls.key_for("gas")` ist `KEY_I`.
  - `test_logische_taste_loest_aus`: `Controls.setup()`; `var e := InputEventKey.new()`; `e.keycode = KEY_ESCAPE`; `e.pressed = true` → `e.is_action("pause")` ist wahr.

Review (17.10.2026): gemergt.
