---
id: T-0081
title: Eingabe der Spielerzelle (PlayerInput)
project: zellenphase
priority: 4
---
## Ziel
Wie bei Spore schwimmt die Zelle mit gedrückter Maustaste in Richtung Mauszeiger; ohne Maus steuern WASD/Pfeiltasten. Eine testbare Funktion macht daraus die Wunschrichtung.

## Dateien
- `scripts/player_input.gd`: neu
- `tests/test_player_input.gd`: neu

## Akzeptanzkriterien
`scripts/player_input.gd` genau so:
```gdscript
class_name PlayerInput
extends RefCounted
## Wunschrichtung der Spielerzelle aus Tasten und Maus.

## Liegt der Mauszeiger näher als das an der Zelle, bleibt sie stehen (kein Zittern).
const DEAD_ZONE := 12.0


## keys: Richtung aus WASD/Pfeiltasten. mouse_held: Maustaste gedrückt.
## mouse_world und cell_pos in Weltkoordinaten. Ergebnis hat Länge 1 oder ist Vector2.ZERO
## (bei Tasten auch kürzer, z. B. bei halb gedrücktem Gamepad).
static func wish(keys: Vector2, mouse_held: bool, mouse_world: Vector2, cell_pos: Vector2) -> Vector2:
	if mouse_held:
		var offset := mouse_world - cell_pos
		if offset.length() < DEAD_ZONE:
			return Vector2.ZERO
		return offset.normalized()
	if keys.length() > 1.0:
		return keys.normalized()
	return keys
```

## Tests
`tests/test_player_input.gd` mit `extends "res://tests/base_test.gd"`:
- `test_tasten`: `PlayerInput.wish(Vector2(1, 0), false, Vector2.ZERO, Vector2.ZERO)` ist `Vector2(1, 0)`
- `test_tasten_schraeg`: `PlayerInput.wish(Vector2(1, 1), false, Vector2.ZERO, Vector2.ZERO).length()` ist 1.0
- `test_maus`: `PlayerInput.wish(Vector2.ZERO, true, Vector2(100, 0), Vector2.ZERO)` ist `Vector2(1, 0)`
- `test_maus_relativ_zur_zelle`: `PlayerInput.wish(Vector2.ZERO, true, Vector2(50, 150), Vector2(50, 50))` ist `Vector2(0, 1)`
- `test_maus_totzone`: `PlayerInput.wish(Vector2.ZERO, true, Vector2(5, 5), Vector2.ZERO)` ist `Vector2.ZERO`
- `test_maus_vor_tasten`: `PlayerInput.wish(Vector2(-1, 0), true, Vector2(0, 100), Vector2.ZERO)` ist `Vector2(0, 1)`
- `test_ohne_eingabe`: `PlayerInput.wish(Vector2.ZERO, false, Vector2(100, 0), Vector2.ZERO)` ist `Vector2.ZERO`

Review (16.10.2026): gemergt.
