---
id: T-0086
title: Nahrung im Wasser (FoodItem, FoodField)
project: zellenphase
priority: 4
after: T-0084
---
## Ziel
Pflanzenstücke und Fleischbrocken schweben im Wasser. Ein `FoodField` verteilt sie reproduzierbar (fester Zufallsstartwert) um einen Punkt und findet das nächste Stück einer Sorte.

## Dateien
- `scripts/food_item.gd`: neu
- `scripts/food_field.gd`: neu
- `tests/test_food_field.gd`: neu

## Akzeptanzkriterien
- `scripts/food_item.gd` genau so:
```gdscript
class_name FoodItem
extends RefCounted
## Ein Nahrungsstück: Sorte (Diet.PFLANZE oder Diet.FLEISCH), Lage, Nährwert, Radius.

var kind: String
var position: Vector2
var value: int
var radius: float


func _init(p_kind: String = Diet.PFLANZE, p_position: Vector2 = Vector2.ZERO, p_value: int = 1, p_radius: float = 5.0) -> void:
	kind = p_kind
	position = p_position
	value = p_value
	radius = p_radius
```
- `scripts/food_field.gd` mit `class_name FoodField`, `extends RefCounted` und:
  - Konstanten `PLANT_VALUE := 1`, `MEAT_VALUE := 2`, `PLANT_RADIUS := 5.0`, `MEAT_RADIUS := 6.0`
  - `var items: Array[FoodItem] = []` und `var rng := RandomNumberGenerator.new()`
  - `func _init(seed_value: int = 1) -> void:` setzt `rng.seed = seed_value`
  - `func add_item(kind: String, pos: Vector2) -> FoodItem`: legt ein Stück an (Fleisch mit `MEAT_VALUE`/`MEAT_RADIUS`, sonst `PLANT_VALUE`/`PLANT_RADIUS`), hängt es an `items` an und gibt es zurück
  - `func spawn_around(center: Vector2, count: int, min_dist: float, max_dist: float, meat_share: float) -> void`: für jedes Stück `var angle := rng.randf() * TAU`, `var dist := rng.randf_range(min_dist, max_dist)`, Lage `center + Vector2.from_angle(angle) * dist`; Sorte Fleisch, wenn `rng.randf() < meat_share`, sonst Pflanze; anlegen mit `add_item`
  - `func count_kind(kind: String) -> int`: Anzahl der Stücke dieser Sorte
  - `func nearest(pos: Vector2, kind: String, max_dist: float = INF) -> FoodItem`: das nächste Stück dieser Sorte mit Abstand ≤ `max_dist`, sonst `null`
  - `func remove_far(center: Vector2, max_dist: float) -> int`: entfernt alle Stücke mit Abstand > `max_dist` von `center`, gibt deren Anzahl zurück

## Tests
`tests/test_food_field.gd` mit `extends "res://tests/base_test.gd"`:
- `test_verteilen`: `FoodField.new(5)`, `spawn_around(Vector2(100, 0), 50, 60.0, 900.0, 0.3)` → `items.size()` ist 50; für jedes Stück liegt `position.distance_to(Vector2(100, 0))` zwischen 59.99 und 900.01
- `test_nur_pflanzen`: `spawn_around(Vector2.ZERO, 20, 10.0, 50.0, 0.0)` → `count_kind(Diet.FLEISCH)` ist 0, `count_kind(Diet.PFLANZE)` ist 20
- `test_nur_fleisch`: mit `meat_share` 1.0 → alle Stücke haben `kind == Diet.FLEISCH` und `value == 2`
- `test_reproduzierbar`: zwei Felder mit `FoodField.new(5)` und gleichem `spawn_around(Vector2.ZERO, 3, 10.0, 50.0, 0.5)` → `items[0].position` und `items[2].position` sind jeweils gleich
- `test_hinzufuegen`: `add_item(Diet.PFLANZE, Vector2(10, 0))` → `value` 1, `radius` 5.0, `items.size()` 1
- `test_naechstes`: Stücke Pflanze bei (100, 0), Fleisch bei (50, 0), Pflanze bei (200, 0) → `nearest(Vector2.ZERO, Diet.PFLANZE).position` ist (100, 0); `nearest(Vector2.ZERO, Diet.FLEISCH, 40.0)` ist `null`
- `test_entfernen`: dieselben drei Stücke, `remove_far(Vector2.ZERO, 150.0)` ist 1, danach `items.size()` 2

Review (16.10.2026): gemergt, nachgebessert: FoodField.nearest nutzt INF statt eigener Konstante INF_DIST
