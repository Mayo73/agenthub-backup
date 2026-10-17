---
id: T-0170
title: Schlängelnde Geißel berechnen (PartAnimation)
project: zellenphase
priority: 2
---
## Ziel
Das Lastenheft verlangt „animierte Körperteile“. Diese Klasse berechnet eine schlängelnde Geißel und rechnet Punkte eines Teils in Pixel um; gezeichnet wird in einem späteren Ticket.

## Dateien
- `scripts/part_animation.gd`: neu
- `tests/test_part_animation.gd`: neu

## Akzeptanzkriterien
`scripts/part_animation.gd` genau so:
```gdscript
class_name PartAnimation
extends RefCounted
## Bewegte Teile: Die Geißel schlängelt. Punkte in Zellradien, Ansatz bei (0, 0), Geißel nach -x.

const FLAGELLUM_POINTS := 8
const FLAGELLUM_LENGTH := 0.9
const FLAGELLUM_AMPLITUDE := 0.12
const FLAGELLUM_SPEED := 10.0


## Linienzug der Geißel zur Zeit time. Der Ansatz bewegt sich nicht, das Ende schwingt am stärksten.
static func flagellum(time: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in FLAGELLUM_POINTS:
		var t := float(i) / (FLAGELLUM_POINTS - 1)
		out.append(Vector2(-FLAGELLUM_LENGTH * t, FLAGELLUM_AMPLITUDE * t * sin(time * FLAGELLUM_SPEED - t * 6.0)))
	return out


## Setzt Punkte (in Zellradien, nach -x zeigend) an ein eingebautes Antriebsteil, Ergebnis in Pixeln
## relativ zur Zellmitte. Wie in PartShapes.placed hängen Antriebe von der Zelle nach außen.
static func place_points(points: PackedVector2Array, part: Dictionary, radius: float) -> PackedVector2Array:
	var pos: Vector2 = part["pos"]
	var angle: float = part["angle"]
	if pos != Vector2.ZERO:
		angle = pos.angle() + PI
	var out := PackedVector2Array()
	for p in points:
		out.append(pos * radius + (p * radius).rotated(angle))
	return out
```

## Tests
`tests/test_part_animation.gd` mit `extends "res://tests/base_test.gd"`:
- `test_punkte`: `var f := PartAnimation.flagellum(0.0)` → `f.size()` ist 8; `f[0].is_equal_approx(Vector2.ZERO)` wahr; `f[7].x` ist -0.9
- `test_schwingt`: `PartAnimation.flagellum(0.0)[7].y` ist `0.12 * sin(-6.0)`; `PartAnimation.flagellum(0.1)[7].y` ist `0.12 * sin(1.0 - 6.0)`
- `test_ansatz_ruhig`: für `t` in `[0.0, 0.3, 2.0]`: `PartAnimation.flagellum(t)[0].is_equal_approx(Vector2.ZERO)` wahr
- `test_hinten`: `var p := PartAnimation.place_points(PackedVector2Array([Vector2(-1, 0)]), {"id": "geissel", "pos": Vector2(-1, 0), "angle": 0.0}, 10.0)` → `p[0].is_equal_approx(Vector2(-20, 0))` wahr
- `test_seitlich`: `var p := PartAnimation.place_points(PackedVector2Array([Vector2.ZERO, Vector2(-1, 0)]), {"id": "geissel", "pos": Vector2(0, 1), "angle": 0.0}, 10.0)` → `p[0].is_equal_approx(Vector2(0, 10))` wahr; `p[1].is_equal_approx(Vector2(0, 20))` wahr

Review (16.10.2026): gemergt.
