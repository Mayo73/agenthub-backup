---
id: T-0061
title: Tastenbelegung ändern (Controls)
project: drift
priority: 3
---
## Ziel
`Controls` bekommt Funktionen, um die Taste einer Aktion auszulesen, zu ändern und die Standardbelegung wiederherzustellen, dazu deutsche Namen der Aktionen. Darauf baut später das Einstellungsmenü auf.

## Dateien
- `scripts/controls.gd`: Konstante und Funktionen ergänzen, `setup()` und `_add()` nicht ändern
- `tests/test_controls.gd`: `teardown()` und Tests anhängen, bestehende Tests nicht ändern

## Akzeptanzkriterien
In `scripts/controls.gd` direkt unter `const ACTIONS := …`:
```gdscript
const LABELS := {
	"gas": "Gas", "bremse": "Bremse", "links": "Links", "rechts": "Rechts",
	"handbremse": "Handbremse", "zuruecksetzen": "Zurücksetzen", "neustart": "Neustart", "pause": "Pause",
}
```
Am Ende der Datei anhängen:
```gdscript


## Erste Taste (physical_keycode) einer Aktion, 0 wenn es keine gibt.
static func key_for(action: String) -> int:
	if not InputMap.has_action(action):
		return 0
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return event.physical_keycode
	return 0


## Ersetzt alle Tasten einer Aktion durch genau eine. Gamepad-Belegungen bleiben.
static func rebind_key(action: String, keycode: int) -> void:
	if not InputMap.has_action(action):
		return
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			InputMap.action_erase_event(action, event)
	var key_event := InputEventKey.new()
	key_event.physical_keycode = keycode
	InputMap.action_add_event(action, key_event)


## Übernimmt geänderte Tasten (Aktion → Tastencode). Unbekannte Aktionen und Codes <= 0 werden ignoriert.
static func apply_bindings(keys: Dictionary) -> void:
	for action in keys:
		if action in ACTIONS and int(keys[action]) > 0:
			rebind_key(action, int(keys[action]))


## Stellt die Standardbelegung wieder her.
static func reset_defaults() -> void:
	for action in ACTIONS:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
	setup()


## Lesbarer Name einer Taste, „–“ für keine.
static func key_name(keycode: int) -> String:
	return OS.get_keycode_string(keycode) if keycode > 0 else "–"
```

## Tests
In `tests/test_controls.gd`:
- neue Funktion `func teardown() -> void:` mit `Controls.reset_defaults()`
- `test_taste_lesen`: `Controls.setup()` → `Controls.key_for("gas")` ist `KEY_W`; `Controls.key_for("gibtsnicht")` ist 0
- `test_taste_aendern`: `Controls.setup()`, `Controls.rebind_key("gas", KEY_I)` → `Controls.key_for("gas")` ist `KEY_I`; unter `InputMap.action_get_events("gas")` gibt es genau 1 `InputEventKey` und genau 1 Ereignis, das kein `InputEventKey` ist (der Gamepad-Trigger)
- `test_belegung_anwenden`: `Controls.setup()`, `Controls.apply_bindings({"bremse": 75.0, "quatsch": 5})` → `Controls.key_for("bremse")` ist 75; `InputMap.has_action("quatsch")` ist falsch
- `test_zuruecksetzen`: `Controls.setup()`, `Controls.rebind_key("gas", KEY_I)`, `Controls.reset_defaults()` → `Controls.key_for("gas")` ist `KEY_W`
- `test_namen`: `Controls.LABELS.size()` ist `Controls.ACTIONS.size()`; `Controls.key_name(KEY_W)` ist `"W"`; `Controls.key_name(0)` ist `"–"`

Review (16.10.2026): gemergt.
