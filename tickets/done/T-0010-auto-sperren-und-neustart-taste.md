---
id: T-0010
title: Auto-Eingaben sperrbar und Taste „neustart“
project: drift
priority: 3
---
## Ziel
Für den Rennablauf muss das Auto während des Countdowns und nach dem Ziel stillhalten, und es braucht eine Taste für ein neues Rennen. Dafür bekommt das Auto einen Schalter `input_enabled` und `Controls` eine neue Aktion `neustart`. Noch nicht in `main.gd` einbauen.

## Dateien
- `scripts/car.gd`: Schalter `input_enabled`
- `scripts/controls.gd`: Aktion `neustart`
- `tests/test_car_input.gd`: neu

## Akzeptanzkriterien
- `scripts/car.gd`: neue Variable `var input_enabled := true` (unter `var track: TrackPath`).
  In `_physics_process` werden die vier Eingaben wie bisher gelesen, wenn `input_enabled` wahr ist. Ist es falsch, gilt stattdessen `physics.throttle = 0.0`, `physics.brake = 0.0`, `physics.steer = 0.0`, `physics.handbrake = false`. Alles andere in `_physics_process` (Untergrund, `physics.step`, Zurücksetzen, Position) bleibt unverändert.
- `scripts/controls.gd`:
  - `"neustart"` hinten an `ACTIONS` anhängen.
  - In `setup()` als letzte Zeile: `_add("neustart", [KEY_ENTER, KEY_KP_ENTER], [JOY_BUTTON_START], [])`
- Keine anderen Dateien ändern. `tests/test_controls.gd` prüft die neue Aktion automatisch mit.

## Tests
Neue Datei `tests/test_car_input.gd` mit `extends "res://tests/base_test.gd"`:

```gdscript
var car: Node2D

func setup() -> void:
	Controls.setup()
	car = load("res://scenes/car.tscn").instantiate()

func teardown() -> void:
	Input.action_release("gas")
	car.free()
	car = null
```

- `test_eingabe_aktiv`: `Input.action_press("gas")`, `car._physics_process(0.1)` → `car.physics.throttle` ist 1.0
- `test_eingabe_gesperrt`: `car.input_enabled = false`, `Input.action_press("gas")`, `car._physics_process(0.1)` → `car.physics.throttle` ist 0.0 und `car.physics.handbrake` ist falsch
- `test_neustart_taste`: `InputMap.has_action("neustart")` ist wahr

Review (15.10.2026): gemergt; Konflikt mit T-0008 in car.gd selbst aufgelöst (Rauch nur setzen, wenn _ready lief).
