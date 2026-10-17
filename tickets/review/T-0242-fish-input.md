---
id: T-0242
title: Fischphase – Tasten für Auf- und Abtauchen (Controls, FishInput)
project: zellenphase
priority: 3
---
## Ziel
Steuerung der Fischphase: W, Pfeil hoch oder linke Maustaste schwimmen vorwärts, S rückwärts, A/D drehen, Leertaste taucht auf, Umschalt oder Strg taucht ab. Dazu zwei neue Aktionen und eine Klasse, die die Tasten in Schwimmbefehle für `FishMotion.step()` übersetzt.

## Dateien
- `scripts/controls.gd`
- `scripts/fish_input.gd` – neu
- `tests/test_fish_input.gd` – neu

## Akzeptanzkriterien
- `scripts/controls.gd`:
  - `const ACTIONS` um `"auftauchen", "abtauchen"` am Ende erweitern;
  - in `setup()` am Ende anfügen:
```gdscript
	_add("auftauchen", [KEY_SPACE], [])
	_add("abtauchen", [KEY_SHIFT, KEY_CTRL], [])
```
- `scripts/fish_input.gd` genau so:
```gdscript
class_name FishInput
extends RefCounted
## Übersetzt Tasten in Schwimmbefehle für FishMotion.step().


## Ergebnis Vector3(thrust, turn, climb): thrust 1 vorwärts, -0.5 rückwärts; turn 1 links, -1 rechts; climb 1 auf, -1 ab.
static func combine(forward: bool, back: bool, left: bool, right: bool, up: bool, down: bool) -> Vector3:
	var thrust := 0.0
	if forward:
		thrust += 1.0
	if back:
		thrust -= 0.5
	var turn := 0.0
	if left:
		turn += 1.0
	if right:
		turn -= 1.0
	var climb := 0.0
	if up:
		climb += 1.0
	if down:
		climb -= 1.0
	return Vector3(thrust, turn, climb)


## Liest die Aktionen: "hoch" oder "schwimmen" vorwärts, "runter" rückwärts, "links"/"rechts" drehen,
## "auftauchen"/"abtauchen" neigen.
static func read() -> Vector3:
	return combine(
		Input.is_action_pressed("hoch") or Input.is_action_pressed("schwimmen"),
		Input.is_action_pressed("runter"),
		Input.is_action_pressed("links"),
		Input.is_action_pressed("rechts"),
		Input.is_action_pressed("auftauchen"),
		Input.is_action_pressed("abtauchen"))
```
- Keine anderen Dateien ändern.

## Tests
`tests/test_fish_input.gd` mit `extends "res://tests/base_test.gd"`:
- `test_nichts`: `FishInput.combine(false, false, false, false, false, false)` ist `Vector3.ZERO`
- `test_vorwaerts`: `FishInput.combine(true, false, false, false, false, false)` ist `Vector3(1, 0, 0)`
- `test_rueckwaerts`: `FishInput.combine(false, true, false, false, false, false)` ist `Vector3(-0.5, 0, 0)`
- `test_drehen`: `FishInput.combine(false, false, true, false, false, false)` ist `Vector3(0, 1, 0)`; `FishInput.combine(false, false, false, true, false, false)` ist `Vector3(0, -1, 0)`; `FishInput.combine(false, false, true, true, false, false)` ist `Vector3.ZERO`
- `test_tauchen`: `FishInput.combine(false, false, false, false, true, false)` ist `Vector3(0, 0, 1)`; `FishInput.combine(true, false, false, false, false, true)` ist `Vector3(1, 0, -1)`
- `test_aktionen`: `Controls.setup()` → `InputMap.has_action("auftauchen")` wahr; `InputMap.has_action("abtauchen")` wahr; `Controls.ACTIONS.has("auftauchen")` wahr
- `test_ohne_tasten`: `Controls.setup()` → `FishInput.read()` ist `Vector3.ZERO`
