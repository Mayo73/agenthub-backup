---
id: T-0194
title: Besiegte Zellen platzen in Bruchstücke (DeathBursts, DeathBurstView)
project: zellenphase
priority: 3
---
## Ziel
Wenn eine Zelle stirbt, verschwindet sie bisher einfach. Künftig platzt sie: Bruchstücke in ihrer Farbe fliegen auseinander und verblassen (Lastenheft: „Trefferreaktionen, Tod“). Hier Logik und Darstellung; eingebaut wird in einem Folgeticket.

## Dateien
- `scripts/death_bursts.gd`: neu
- `scripts/death_burst_view.gd`: neu
- `tests/test_death_bursts.gd`: neu

## Akzeptanzkriterien
`scripts/death_bursts.gd` genau so:
```gdscript
class_name DeathBursts
extends RefCounted
## Geplatzte Zellen: Bruchstücke fliegen auseinander und verblassen.

const DURATION := 0.6
const PIECES := 10
const MAX_BURSTS := 12

## Je Platzen ein Dictionary mit "pos" (Vector2), "radius" (float), "color" (Color) und "age" (float).
var bursts: Array = []


func add(pos: Vector2, radius: float, color: Color) -> void:
	bursts.append({"pos": pos, "radius": radius, "color": color, "age": 0.0})
	if bursts.size() > MAX_BURSTS:
		bursts.pop_front()


func tick(delta: float) -> void:
	var kept := []
	for b: Dictionary in bursts:
		b["age"] = float(b["age"]) + delta
		if b["age"] < DURATION:
			kept.append(b)
	bursts = kept


## Fortschritt von 0 (gerade geplatzt) bis 1 (vorbei).
static func progress(age: float) -> float:
	return clampf(age / DURATION, 0.0, 1.0)


## Lage der Bruchstücke: gleichmäßig rundum, sie fliegen von 0,5 auf 2 Radien hinaus.
static func pieces(center: Vector2, radius: float, age: float) -> PackedVector2Array:
	var dist := radius * (0.5 + 1.5 * progress(age))
	var out := PackedVector2Array()
	for i in PIECES:
		out.append(center + Vector2.from_angle(TAU * i / PIECES) * dist)
	return out


## Größe eines Bruchstücks: schrumpft von 0,3 Radien auf 0.
static func piece_size(radius: float, age: float) -> float:
	return radius * 0.3 * (1.0 - progress(age))
```
`scripts/death_burst_view.gd` genau so:
```gdscript
class_name DeathBurstView
extends Node2D
## Zeichnet die Bruchstücke geplatzter Zellen und lässt sie altern.

var bursts := DeathBursts.new()


func _process(delta: float) -> void:
	bursts.tick(delta)
	queue_redraw()


func _draw() -> void:
	for b: Dictionary in bursts.bursts:
		var c: Color = b["color"]
		c.a = 0.8 * (1.0 - DeathBursts.progress(b["age"]))
		for p in DeathBursts.pieces(b["pos"], b["radius"], b["age"]):
			draw_circle(p, DeathBursts.piece_size(b["radius"], b["age"]), c)
```

## Tests
`tests/test_death_bursts.gd` mit `extends "res://tests/base_test.gd"`, `var d: DeathBursts`; `setup()`: `d = DeathBursts.new()`.
- `test_platzen`: `d.add(Vector2(5, 5), 10.0, Color.RED)` → `d.bursts.size()` ist 1; `d.bursts[0]["radius"]` ist 10.0
- `test_altern`: `d.add(Vector2.ZERO, 10.0, Color.RED)`, `d.tick(0.3)` → `d.bursts.size()` ist 1; `d.bursts[0]["age"]` ist 0.3; `d.tick(0.4)` → `d.bursts.size()` ist 0
- `test_hoechstzahl`: 15-mal `d.add(Vector2.ZERO, 5.0, Color.RED)` → `d.bursts.size()` ist 12
- `test_fortschritt`: `DeathBursts.progress(0.0)` ist 0.0; `DeathBursts.progress(0.3)` ist 0.5; `DeathBursts.progress(5.0)` ist 1.0
- `test_bruchstuecke`: `var p := DeathBursts.pieces(Vector2.ZERO, 10.0, 0.0)` → `p.size()` ist 10; `p[0].is_equal_approx(Vector2(5, 0))` wahr; `DeathBursts.pieces(Vector2(1, 1), 10.0, 0.6)[0].is_equal_approx(Vector2(21, 1))` wahr
- `test_groesse`: `DeathBursts.piece_size(10.0, 0.0)` ist 3.0; `DeathBursts.piece_size(10.0, 0.3)` ist 1.5
- `test_view`: `var v := DeathBurstView.new()`, `v.bursts.add(Vector2.ZERO, 10.0, Color.RED)`, `v._process(1.0)` → `v.bursts.bursts.size()` ist 0; danach `v.free()`

Review (17.10.2026): gemergt.
