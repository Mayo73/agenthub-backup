---
id: T-0273
title: FishSchool – Fische in der Welt verteilen
project: zellenphase
priority: 4
after: T-0269, T-0272
---
## Ziel
Meilenstein „Fischphase – Leben im Meer“: Legt fest, wo welche Fische zu Beginn schwimmen (zwei Silberling-Schwärme, einige Grasfische, zwei Zackenbarsche, alle mit Abstand zum Spieler), und berechnet die Mitte eines Schwarms.

## Dateien
- `scripts/fish_school.gd` – neu
- `tests/test_fish_school.gd` – neu

## Akzeptanzkriterien
Neue Datei `scripts/fish_school.gd`, genau so:
```gdscript
class_name FishSchool
extends RefCounted
## Verteilung der KI-Fische und Schwarmmitte.

## Waagrechter Abstand der Fische zum Spieler beim Verteilen, in Metern.
const MIN_DIST := 20.0
const MAX_DIST := 60.0
const SWARMS := 2
const SWARM_SIZE := 6
const GRAZERS := 3
const PREDATORS := 2


## Plan: Liste von {"id": String, "position": Vector3}. Gleicher seed, gleicher Plan.
static func spawn_plan(center: Vector3, seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var plan: Array[Dictionary] = []
	for s in SWARMS:
		var mid := _around(center, rng)
		for i in SWARM_SIZE:
			var offset := Vector3(rng.randf_range(-2.0, 2.0), rng.randf_range(-1.0, 1.0), rng.randf_range(-2.0, 2.0))
			plan.append({"id": "silberling", "position": FishWorld.clamp_to_water(mid + offset)})
	for i in GRAZERS:
		plan.append({"id": "grasfisch", "position": _around(center, rng)})
	for i in PREDATORS:
		plan.append({"id": "zackenbarsch", "position": _around(center, rng)})
	return plan


## Zufällige Lage im waagrechten Abstand MIN_DIST bis MAX_DIST (Schwarmversatz bis 2 m kommt dazu), Tiefe 5 bis 50 m.
static func _around(center: Vector3, rng: RandomNumberGenerator) -> Vector3:
	var angle := rng.randf_range(0.0, TAU)
	var dist := rng.randf_range(MIN_DIST + 3.0, MAX_DIST)
	var p := center + Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)
	p.y = -rng.randf_range(5.0, 50.0)
	return FishWorld.clamp_to_water(p)


## Mitte aller Fische einer Art (Knoten mit species_id und motion), null wenn es keinen gibt.
static func flock_center(fishes: Array, species_id: String) -> Variant:
	var sum := Vector3.ZERO
	var n := 0
	for f in fishes:
		if f.species_id == species_id:
			sum += f.motion.position
			n += 1
	if n == 0:
		return null
	return sum / n
```

## Tests
Neue Datei `tests/test_fish_school.gd` (`extends "res://tests/base_test.gd"`):
- `test_anzahl`: `spawn_plan(FishWorld.START, 7)` hat 17 Einträge: 12 `"silberling"`, 3 `"grasfisch"`, 2 `"zackenbarsch"`
- `test_abstand`: jeder Eintrag liegt waagrecht (nur x und z) mindestens 20 m von `FishWorld.START` entfernt und ist gleich `FishWorld.clamp_to_water(position)` (liegt im Wasser)
- `test_gleicher_seed`: zweimal `spawn_plan(FishWorld.START, 7)` ergibt dasselbe (`==`); mit seed 8 etwas anderes
- `test_schwarmmitte`: zwei `AiFish` mit `setup("silberling", Vector3(0, -20, 0))` und `setup("silberling", Vector3(4, -20, 0))`, ein dritter `setup("grasfisch", Vector3(50, -20, 0))` → `flock_center([a, b, c], "silberling")` ist `Vector3(2, -20, 0)`; `flock_center([c], "silberling")` ist `null`. Alle drei am Ende `free()`.

Review (17.10.2026): gemergt.
