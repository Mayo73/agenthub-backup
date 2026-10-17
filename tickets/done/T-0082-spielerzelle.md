---
id: T-0082
title: Spielerzelle als Node, Kamera folgt
project: zellenphase
priority: 4
after: T-0080, T-0081
---
## Ziel
Die Spielerzelle erscheint in der Hauptszene, schwimmt mit Maus oder Tasten und die Kamera folgt ihr.

## Dateien
- `scripts/player_cell.gd`: neu
- `scripts/main.gd`
- `tests/test_player_cell.gd`: neu
- `tests/test_main_wiring.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `scripts/player_cell.gd` genau so:
```gdscript
class_name PlayerCell
extends Node2D
## Die Zelle des Spielers. Bewegung in CellMotion, Darstellung als Platzhalter mit _draw().

const COLOR := Color(0.5, 0.88, 0.82)
const MOUTH_COLOR := Color(0.1, 0.3, 0.3)

var motion := CellMotion.new()
var radius := 12.0
var input_enabled := true


func _physics_process(delta: float) -> void:
	if not input_enabled:
		drive(delta, Vector2.ZERO)
		return
	var mouse_held := Input.is_action_pressed("schwimmen")
	drive(delta, PlayerInput.wish(Controls.key_vector(), mouse_held, get_global_mouse_position(), global_position))


## Bewegt die Zelle um einen Zeitschritt und überträgt Lage und Ausrichtung auf den Node.
func drive(delta: float, wish: Vector2) -> void:
	motion.step(delta, wish)
	position = motion.position
	rotation = motion.heading
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, COLOR)
	draw_circle(Vector2(radius * 0.8, 0), radius * 0.25, MOUTH_COLOR)
```
- `scripts/main.gd`: neue Variable `var player: PlayerCell` unter den `@onready`-Zeilen. In `_ready()` nach `Controls.setup()`:
```gdscript
	player = PlayerCell.new()
	player.name = "Player"
	world.add_child(player)
```
  Neue Funktion am Ende:
```gdscript
func _process(_delta: float) -> void:
	camera.position = player.position
```

## Tests
- `tests/test_player_cell.gd` mit `extends "res://tests/base_test.gd"`, `var cell: PlayerCell`; `setup()`: `cell = PlayerCell.new()`; `teardown()`: `cell.free()`.
  - `test_schwimmen`: `cell.drive(0.1, Vector2.RIGHT)` → `cell.position.x` ist 6.0, `cell.rotation` ist 0.0
  - `test_drehen`: `cell.drive(0.1, Vector2.UP)` → `cell.rotation` ist -0.6
- `tests/test_main_wiring.gd`, neue Methode `test_spieler`: `main.player is PlayerCell` ist wahr; `main.player.get_parent() == main.world` ist wahr; nach `main.player.drive(0.1, Vector2.RIGHT)` und `main._process(0.016)` ist `main.camera.position` gleich `main.player.position` (mit `check_eq` auf `.x` und `.y`).

Review (16.10.2026): gemergt.
