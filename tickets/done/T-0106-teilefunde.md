---
id: T-0106
title: Teilefunde im Wasser (PartPickups)
project: zellenphase
priority: 3
---
## Ziel
Wie die Meteoritensplitter bei Spore liegen Teilefunde im Wasser. Wer einen berührt, bekommt ein neues Teil. Diese Klasse verwaltet nur die Lagen der Funde.

## Dateien
- `scripts/part_pickups.gd`: neu
- `tests/test_part_pickups.gd`: neu

## Akzeptanzkriterien
`scripts/part_pickups.gd` genau so (wichtig: gefilterte Listen immer mit einer Schleife in ein typisiertes `Array[Vector2]` sammeln, nicht mit `filter()`, sonst gibt es einen Typfehler):
```gdscript
class_name PartPickups
extends RefCounted
## Teilefunde im Wasser (wie die Meteoritensplitter bei Spore). Wer einen berührt, bekommt ein neues Teil.

const RADIUS := 9.0

var positions: Array[Vector2] = []
var rng := RandomNumberGenerator.new()


func _init(seed_value: int = 1) -> void:
	rng.seed = seed_value


## Legt einen Fund im Ring um center an und gibt seine Lage zurück.
func spawn_around(center: Vector2, min_dist: float, max_dist: float) -> Vector2:
	var pos := center + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(min_dist, max_dist)
	positions.append(pos)
	return pos


## Entfernt alle Funde, die den Kreis um center mit radius berühren, und gibt ihre Anzahl zurück.
func take_touching(center: Vector2, radius: float) -> int:
	var kept: Array[Vector2] = []
	for p in positions:
		if center.distance_to(p) > radius + RADIUS:
			kept.append(p)
	var taken := positions.size() - kept.size()
	positions = kept
	return taken


## Entfernt alle Funde, die weiter als max_dist von center liegen, und gibt ihre Anzahl zurück.
func remove_far(center: Vector2, max_dist: float) -> int:
	var kept: Array[Vector2] = []
	for p in positions:
		if center.distance_to(p) <= max_dist:
			kept.append(p)
	var removed := positions.size() - kept.size()
	positions = kept
	return removed
```

## Tests
`tests/test_part_pickups.gd` mit `extends "res://tests/base_test.gd"`:
- `test_ring`: `var p := PartPickups.new(4)`; 20-mal `p.spawn_around(Vector2(100, 0), 50.0, 80.0)` → `p.positions.size()` ist 20, jeder Abstand zu (100, 0) liegt zwischen 49.99 und 80.01
- `test_reproduzierbar`: zwei `PartPickups.new(4)`, je einmal `spawn_around(Vector2.ZERO, 50.0, 80.0)` → die beiden Rückgabewerte sind gleich
- `test_beruehren`: `p.positions.append(Vector2(20, 0))` und `p.positions.append(Vector2(100, 0))`; `p.take_touching(Vector2.ZERO, 12.0)` ist 1, `p.positions.size()` ist 1; nochmals `take_touching(Vector2.ZERO, 12.0)` ist 0
- `test_weit_weg`: `p.positions.append(Vector2(20, 0))` und `p.positions.append(Vector2(100, 0))`; `p.remove_far(Vector2.ZERO, 50.0)` ist 1, `p.positions[0]` ist (20, 0)

Review (16.10.2026): gemergt.
