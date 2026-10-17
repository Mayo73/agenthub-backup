---
id: T-0219
title: Zickzacklinie für Blitze (ElectricArcs)
project: zellenphase
priority: 2
---
## Ziel
Für die Entladung des Elektroorgans eine Zickzacklinie berechnen, damit der Blitz später sichtbar gezeichnet werden kann.

## Dateien
- `scripts/electric_arcs.gd` – neu
- `tests/test_electric_arcs.gd` – neu

## Akzeptanzkriterien
`scripts/electric_arcs.gd` genau so:
```gdscript
class_name ElectricArcs
extends RefCounted
## Zickzacklinie eines Blitzes von from nach to.


## segments Teilstücke (mindestens 1), also segments + 1 Punkte. Die inneren Punkte weichen
## höchstens jitter Pixel quer zur Linie ab; gleicher seed_value ergibt dieselbe Linie.
static func arc(from: Vector2, to: Vector2, segments: int, jitter: float, seed_value: int) -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var n := maxi(1, segments)
	var side := (to - from).normalized().orthogonal()
	var points := PackedVector2Array()
	for i in n + 1:
		var p := from.lerp(to, float(i) / n)
		if i > 0 and i < n:
			p += side * rng.randf_range(-jitter, jitter)
		points.append(p)
	return points
```
- Keine andere Datei ändern.

## Tests
`tests/test_electric_arcs.gd` mit `extends "res://tests/base_test.gd"`:
- `test_anzahl`: `ElectricArcs.arc(Vector2.ZERO, Vector2(100, 0), 5, 6.0, 1).size()` ist 6
- `test_enden`: `var a := ElectricArcs.arc(Vector2(10, 20), Vector2(110, 20), 5, 6.0, 3)` → `a[0]` ist `Vector2(10, 20)`; `a[5]` ist `Vector2(110, 20)`
- `test_abweichung`: `var a := ElectricArcs.arc(Vector2.ZERO, Vector2(100, 0), 5, 6.0, 7)`; für `i` von 1 bis 4: `a[i].x` ist `20.0 * i`; `absf(a[i].y) <= 6.0` wahr
- `test_gleicher_seed`: `ElectricArcs.arc(Vector2.ZERO, Vector2(0, 80), 4, 5.0, 9) == ElectricArcs.arc(Vector2.ZERO, Vector2(0, 80), 4, 5.0, 9)` wahr
- `test_mindestens_ein_stueck`: `ElectricArcs.arc(Vector2.ZERO, Vector2(50, 0), 0, 5.0, 1).size()` ist 2

Review (17.10.2026): gemergt.
