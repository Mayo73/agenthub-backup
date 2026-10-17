---
id: T-0164
title: Wogende Zellmembran und Texturkoordinaten (CellBody)
project: zellenphase
priority: 2
---
## Ziel
Zellen sollen lebendig wirken (Lastenheft „räumlich wirkende Zellen“): Die Membran wogt leicht, und der Körper wird mit der Higgsfield-Textur `assets/cells/zellkoerper.png` gefüllt. Diese Klasse rechnet nur Umriss und Texturkoordinaten; gezeichnet wird in einem späteren Ticket.

## Dateien
- `scripts/cell_body.gd`: neu
- `tests/test_cell_body.gd`: neu

## Akzeptanzkriterien
`scripts/cell_body.gd` genau so:
```gdscript
class_name CellBody
extends RefCounted
## Lebendig wirkender Zellkörper: Umriss mit sanft wogender Membran und Texturkoordinaten.

const WAVE_AMOUNT := 0.04
const WAVE_COUNT := 5
const WAVE_SPEED := 2.0


## Umriss aus look.outline(), jeder Punkt um bis zu WAVE_AMOUNT nach außen oder innen verschoben.
static func wobble(look: CellLook, radius: float, time: float, points: int = 32) -> PackedVector2Array:
	var base := look.outline(radius, points)
	var out := PackedVector2Array()
	for i in base.size():
		var a := TAU * i / points
		out.append(base[i] * (1.0 + WAVE_AMOUNT * sin(a * WAVE_COUNT + time * WAVE_SPEED)))
	return out


## Halbe Breite und Höhe des größtmöglichen Umrisses (mit Streckung und Wogen).
static func half_size(look: CellLook, radius: float) -> Vector2:
	var f := 1.0 + WAVE_AMOUNT
	return Vector2(radius * look.stretch * f, radius / look.stretch * f)


## Texturkoordinaten (0 bis 1) zu den Punkten eines Umrisses; die Textur wird mit dem Körper gestreckt.
static func uvs(outline: PackedVector2Array, half: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in outline:
		out.append(Vector2(p.x / (2.0 * half.x), p.y / (2.0 * half.y)) + Vector2(0.5, 0.5))
	return out
```

## Tests
`tests/test_cell_body.gd` mit `extends "res://tests/base_test.gd"`, `var look: CellLook`; `setup()`: `look = CellLook.new()`.
- `test_anzahl`: `CellBody.wobble(look, 10.0, 0.0).size()` ist 32; `CellBody.wobble(look, 10.0, 0.0, 8).size()` ist 8
- `test_erster_punkt`: `CellBody.wobble(look, 10.0, 0.0)[0].is_equal_approx(Vector2(10, 0))` wahr (sin(0) = 0)
- `test_wogen_begrenzt`: für `t` in `[0.0, 0.7, 1.9]` und jeden Punkt `p` von `CellBody.wobble(look, 10.0, t)`: `p.length() <= 10.0 * 1.04 + 0.001` wahr und `p.length() >= 10.0 * 0.96 - 0.001` wahr
- `test_bewegt_sich`: `CellBody.wobble(look, 10.0, 0.0)[3].is_equal_approx(CellBody.wobble(look, 10.0, 0.5)[3])` falsch
- `test_halbe_groesse`: `look.set_stretch(1.25)` → `CellBody.half_size(look, 10.0).is_equal_approx(Vector2(13.0, 8.32))` wahr
- `test_uvs`: `var uv := CellBody.uvs(PackedVector2Array([Vector2(10, 0), Vector2.ZERO, Vector2(0, -5)]), Vector2(10, 5))` → `uv[0].is_equal_approx(Vector2(1.0, 0.5))` wahr; `uv[1].is_equal_approx(Vector2(0.5, 0.5))` wahr; `uv[2].is_equal_approx(Vector2(0.5, 0.0))` wahr

Review (16.10.2026): gemergt.
