---
id: T-0165
title: Muster des Zellkörpers berechnen (CellPattern)
project: zellenphase
priority: 2
---
## Ziel
Im Editor lassen sich die Muster „punkte“, „streifen“ und „flecken“ wählen (`CellLook.PATTERNS`), sie werden aber noch nirgends gezeichnet. Diese Klasse berechnet die Lage der Musterelemente; gezeichnet wird in einem späteren Ticket.

## Dateien
- `scripts/cell_pattern.gd`: neu
- `tests/test_cell_pattern.gd`: neu

## Akzeptanzkriterien
`scripts/cell_pattern.gd` genau so:
```gdscript
class_name CellPattern
extends RefCounted
## Musterelemente des Zellkörpers. Lagen und Größen in Zellradien, (0, 0) = Zellmitte, Blickrichtung +x.

const STRIPE_XS := [-0.6, -0.3, 0.0, 0.3, 0.6]
const STRIPE_REACH := 0.8


## Elemente eines Musters: Dictionaries mit "pos" (Vector2), "size" (float) und "stripe" (bool).
## Gleiches Muster und gleicher seed_value ergeben immer dieselben Elemente.
static func marks(pattern: String, seed_value: int = 7) -> Array:
	var out := []
	if pattern == "streifen":
		for x: float in STRIPE_XS:
			out.append({"pos": Vector2(x, 0.0), "size": 0.06, "stripe": true})
		return out
	var count := 0
	var size := 0.0
	var max_r := 0.0
	if pattern == "punkte":
		count = 12
		size = 0.07
		max_r = 0.7
	elif pattern == "flecken":
		count = 5
		size = 0.17
		max_r = 0.5
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in count:
		var pos := Vector2.from_angle(rng.randf() * TAU) * sqrt(rng.randf()) * max_r
		out.append({"pos": pos, "size": size, "stripe": false})
	return out


## Halbe Länge eines Streifens an der Stelle x (in Zellradien), damit er im Körper bleibt.
static func stripe_half(x: float) -> float:
	return sqrt(maxf(0.0, STRIPE_REACH * STRIPE_REACH - x * x))


## Lage eines Elements in Pixeln, mit der Streckung des Aussehens (wie CellLook.outline).
static func to_local(pos: Vector2, radius: float, look: CellLook) -> Vector2:
	return Vector2(pos.x * radius * look.stretch, pos.y * radius / look.stretch)
```

## Tests
`tests/test_cell_pattern.gd` mit `extends "res://tests/base_test.gd"`:
- `test_keins`: `CellPattern.marks("keins").size()` ist 0; `CellPattern.marks("gibtsnicht").size()` ist 0
- `test_punkte`: `var m := CellPattern.marks("punkte")` → `m.size()` ist 12; für jedes Element `e`: `(e["pos"] as Vector2).length() <= 0.7001` wahr, `e["stripe"]` falsch, `e["size"]` ist 0.07
- `test_flecken`: `CellPattern.marks("flecken").size()` ist 5; für jedes Element `e`: `(e["pos"] as Vector2).length() <= 0.5001` wahr
- `test_streifen`: `var m := CellPattern.marks("streifen")` → `m.size()` ist 5; `m[0]["stripe"]` wahr; `(m[4]["pos"] as Vector2).is_equal_approx(Vector2(0.6, 0))` wahr
- `test_reproduzierbar`: `var a: Vector2 = CellPattern.marks("punkte", 3)[2]["pos"]`, `var b: Vector2 = CellPattern.marks("punkte", 3)[2]["pos"]` → `a.is_equal_approx(b)` wahr
- `test_streifenlaenge`: `CellPattern.stripe_half(0.0)` ist 0.8; `CellPattern.stripe_half(0.6)` liegt zwischen 0.529 und 0.530; `CellPattern.stripe_half(2.0)` ist 0.0
- `test_lage`: `var l := CellLook.new()`, `l.set_stretch(1.25)` → `CellPattern.to_local(Vector2(0.5, 0.5), 10.0, l).is_equal_approx(Vector2(6.25, 4.0))` wahr

Review (16.10.2026): gemergt.
