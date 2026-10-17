---
id: T-0080
title: Bewegung der Zelle (CellMotion)
project: zellenphase
priority: 4
---
## Ziel
Eine testbare Klasse für das Schwimmen einer Zelle: Beschleunigung in Wunschrichtung, Höchsttempo, Trägheit (Ausgleiten ohne Eingabe) und begrenzte Wendegeschwindigkeit.

## Dateien
- `scripts/cell_motion.gd`: neu
- `tests/test_cell_motion.gd`: neu

## Akzeptanzkriterien
`scripts/cell_motion.gd` genau so:
```gdscript
class_name CellMotion
extends RefCounted
## Schwimmbewegung einer Zelle in Weltkoordinaten. heading in Radiant, 0 = nach rechts.

var position := Vector2.ZERO
var velocity := Vector2.ZERO
var heading := 0.0
var acceleration := 600.0
var max_speed := 220.0
## Anteil des Tempos, der ohne Eingabe pro Sekunde verloren geht.
var drag := 2.5
## Wendegeschwindigkeit in Radiant pro Sekunde.
var turn_rate := 6.0


## Ein Zeitschritt. wish = gewünschte Richtung (Länge höchstens 1, sonst wird normalisiert).
func step(delta: float, wish: Vector2) -> void:
	if wish.length() > 1.0:
		wish = wish.normalized()
	if wish != Vector2.ZERO:
		velocity += wish * acceleration * delta
		heading = rotate_toward(heading, wish.angle(), turn_rate * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, velocity.length() * drag * delta)
	velocity = velocity.limit_length(max_speed)
	position += velocity * delta


func speed() -> float:
	return velocity.length()
```

## Tests
`tests/test_cell_motion.gd` mit `extends "res://tests/base_test.gd"`, `var m: CellMotion`, in `setup()`: `m = CellMotion.new()`.
- `test_beschleunigen`: `m.step(0.1, Vector2.RIGHT)` → `m.velocity.x` ist 60.0, `m.position.x` ist 6.0, `m.heading` ist 0.0
- `test_hoechsttempo`: 20-mal `m.step(0.1, Vector2.RIGHT)` → `m.speed()` ist 220.0
- `test_ausgleiten`: 20-mal `m.step(0.1, Vector2.RIGHT)`, dann einmal `m.step(0.1, Vector2.ZERO)` → `m.speed()` ist 165.0
- `test_wenden_begrenzt`: `m.step(0.1, Vector2.UP)` → `m.heading` ist -0.6; danach 9-mal `m.step(0.1, Vector2.UP)` → `m.heading` ist `-PI / 2`
- `test_lange_eingabe_normalisiert`: `m.step(0.1, Vector2(2, 0))` → `m.velocity.x` ist 60.0

Review (16.10.2026): gemergt.
