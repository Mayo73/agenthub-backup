---
id: T-0250
title: Fischphase – Nahrung im 3D-Raum (FishFood)
project: zellenphase
priority: 3
---
## Ziel
In der Fischphase gibt es Algenbüschel (Pflanzennahrung) nahe am Meeresboden und Krebschen (Fleisch) im freien Wasser in allen Tiefen. Wer Nahrung finden will, muss also auf- und abtauchen. Wie in der Zellenphase bestimmt die Ernährung, was gefressen werden kann.

## Dateien
- `scripts/fish_food.gd` – neu
- `tests/test_fish_food.gd` – neu

## Akzeptanzkriterien
`scripts/fish_food.gd` genau so:
```gdscript
class_name FishFood
extends RefCounted
## Nahrung der Fischphase im 3D-Raum: Algenbüschel (Pflanze) nahe am Boden, Krebschen (Fleisch) in jeder Tiefe.

const PLANT_VALUE := 2
const MEAT_VALUE := 3
## Radius eines Nahrungsstücks in Metern.
const ITEM_RADIUS := 0.3

## Je Eintrag: {"kind": Diet.PFLANZE oder Diet.FLEISCH, "position": Vector3, "value": int}
var items: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()


func _init(seed_value: int = 3) -> void:
	rng.seed = seed_value


func add_item(kind: String, pos: Vector3) -> Dictionary:
	var item := {"kind": kind, "position": pos, "value": PLANT_VALUE if kind == Diet.PFLANZE else MEAT_VALUE}
	items.append(item)
	return item


## Streut count Stücke waagrecht im Abstand min_dist bis max_dist um center. Pflanzen liegen 0,5 bis 4 m über
## dem Boden, Fleisch schwebt zwischen 2 m unter der Oberfläche und 2 m über dem Boden. meat_share = Anteil Fleisch.
func spawn_around(center: Vector3, count: int, min_dist: float, max_dist: float, meat_share: float) -> void:
	for i in count:
		var angle := rng.randf() * TAU
		var dist := rng.randf_range(min_dist, max_dist)
		var kind := Diet.FLEISCH if rng.randf() < meat_share else Diet.PFLANZE
		var y: float
		if kind == Diet.PFLANZE:
			y = -FishWorld.DEPTH + rng.randf_range(0.5, 4.0)
		else:
			y = rng.randf_range(-FishWorld.DEPTH + 2.0, -2.0)
		var p := Vector3(center.x + cos(angle) * dist, y, center.z + sin(angle) * dist)
		add_item(kind, FishWorld.clamp_to_water(p))


## Nimmt alle Stücke im Abstand reach um mouth, die zur Ernährung passen, und gibt sie zurück.
func take_at(mouth: Vector3, reach: float, diet: String) -> Array[Dictionary]:
	var taken: Array[Dictionary] = []
	for item in items.duplicate():
		var pos: Vector3 = item["position"]
		if Diet.can_eat(diet, item["kind"]) and mouth.distance_to(pos) <= reach + ITEM_RADIUS:
			taken.append(item)
			items.erase(item)
	return taken


func count_kind(kind: String) -> int:
	var n := 0
	for item in items:
		if item["kind"] == kind:
			n += 1
	return n


## Entfernt Stücke, die waagrecht weiter als max_dist von center entfernt sind. Gibt die Anzahl zurück.
func remove_far(center: Vector3, max_dist: float) -> int:
	var before := items.size()
	var kept: Array[Dictionary] = []
	for item in items:
		var pos: Vector3 = item["position"]
		if Vector2(pos.x - center.x, pos.z - center.z).length() <= max_dist:
			kept.append(item)
	items = kept
	return before - items.size()
```
- Keine andere Datei ändern.

## Tests
`tests/test_fish_food.gd` mit `extends "res://tests/base_test.gd"`, `var food: FishFood`; `setup()`: `food = FishFood.new()`:
- `test_hinzufuegen`: `food.add_item(Diet.PFLANZE, Vector3(1, -50, 0))["value"]` ist 2; `food.add_item(Diet.FLEISCH, Vector3(0, -10, 0))["value"]` ist 3; `food.items.size()` ist 2; `food.count_kind(Diet.FLEISCH)` ist 1
- `test_fressen`: `food.add_item(Diet.PFLANZE, Vector3(0, -20, -1))`; `food.add_item(Diet.PFLANZE, Vector3(0, -20, -5))`; `var t := food.take_at(Vector3(0, -20, -0.8), 0.5, Diet.PFLANZENFRESSER)` → `t.size()` ist 1; `food.items.size()` ist 1
- `test_ernaehrung`: `food.add_item(Diet.FLEISCH, Vector3(0, -20, 0))`; `food.take_at(Vector3(0, -20, 0), 0.5, Diet.PFLANZENFRESSER).size()` ist 0; `food.take_at(Vector3(0, -20, 0), 0.5, Diet.ALLESFRESSER).size()` ist 1
- `test_streuen`: `food.spawn_around(Vector3(0, -20, 0), 50, 5.0, 40.0, 0.4)` → `food.items.size()` ist 50; für jedes Stück: `item["position"].y < 0.0` wahr und `item["position"].y > -FishWorld.DEPTH` wahr; für jede Pflanze: `item["position"].y <= -FishWorld.DEPTH + 4.0` wahr; `food.count_kind(Diet.FLEISCH) > 0` wahr; `food.count_kind(Diet.PFLANZE) > 0` wahr
- `test_entfernen`: `food.add_item(Diet.PFLANZE, Vector3(10, -50, 0))`; `food.add_item(Diet.PFLANZE, Vector3(100, -50, 0))` → `food.remove_far(Vector3(0, -20, 0), 50.0)` ist 1; `food.items.size()` ist 1

Review (17.10.2026): gemergt.
