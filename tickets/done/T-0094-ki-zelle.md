---
id: T-0094
title: KI-Zelle als Node (AiCell)
project: zellenphase
priority: 4
after: T-0087, T-0091, T-0092, T-0093
---
## Ziel
Ein Node für eine andere Zelle: übernimmt Werte aus dem `SpeciesCatalog`, entscheidet mit `AiBrain`, schwimmt mit `CellMotion` und hat eine `CellHealth`. Darstellung vorerst als Kreis in der Farbe der Art.

## Dateien
- `scripts/ai_cell.gd`: neu
- `tests/test_ai_cell.gd`: neu

## Akzeptanzkriterien
`scripts/ai_cell.gd` mit `class_name AiCell`, `extends Node2D` und:
- Variablen: `var species_id := ""`, `var motion := CellMotion.new()`, `var health := CellHealth.new()`, `var brain := AiBrain.new()`, `var radius := 12.0`, `var diet := Diet.PFLANZENFRESSER`, `var damage := 0.0`, `var color := Color.WHITE`, `var wish := Vector2.ZERO`
- Funktionen genau so:
```gdscript
## Übernimmt die Werte der Art und setzt die Zelle an pos.
func setup(id: String, pos: Vector2) -> void:
	var d := SpeciesCatalog.data(id)
	species_id = id
	radius = SpeciesCatalog.radius_of(id)
	diet = d["diet"]
	damage = d["damage"]
	color = d["color"]
	motion.max_speed = d["speed"]
	motion.acceleration = d["speed"] * 2.5
	motion.position = pos
	position = pos
	health = CellHealth.new(d["hp"])


func think(others: Array, food_pos: Variant) -> void:
	wish = brain.decide(motion.position, radius, diet, others, food_pos)


func drive(delta: float) -> void:
	motion.step(delta, wish)
	health.tick(delta)
	position = motion.position
	rotation = motion.heading
	queue_redraw()


func _physics_process(delta: float) -> void:
	drive(delta)


func mouth_point() -> Vector2:
	return MouthContact.mouth_point(motion.position, motion.heading, radius)


## Daten für die Entscheidungen anderer Zellen (siehe AiBrain.decide).
func info() -> Dictionary:
	return {"position": motion.position, "radius": radius, "diet": diet}


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)
	draw_circle(Vector2(radius * 0.8, 0), radius * 0.22, color.darkened(0.5))
```

## Tests
`tests/test_ai_cell.gd` mit `extends "res://tests/base_test.gd"`, `var cell: AiCell`; `setup()`: `cell = AiCell.new()`; `teardown()`: `cell.free()`.
- `test_werte_der_art`: `cell.setup("schnapper", Vector2(50, 0))` → `cell.radius` 18.0, `cell.diet` `Diet.FLEISCHFRESSER`, `cell.health.max_hp` 40.0, `cell.motion.max_speed` 150.0, `cell.position` (50, 0), `cell.damage` 15.0
- `test_jagen_und_schwimmen`: nach `setup("schnapper", Vector2(50, 0))` und `cell.think([{"position": Vector2(150, 0), "radius": 12.0, "diet": Diet.PFLANZENFRESSER}], null)` ist `cell.wish` (1, 0) und `cell.brain.state` `AiBrain.JAGEN`; nach `cell.drive(0.1)` ist `cell.position.x > 50.0`
- `test_info`: nach `setup("blasenling", Vector2(5, 5))` ist `cell.info()["radius"]` 12.0 und `cell.info()["diet"]` `Diet.PFLANZENFRESSER`
- `test_maul`: nach `setup("blasenling", Vector2.ZERO)` ist `cell.mouth_point()` (12, 0)

Review (16.10.2026): gemergt, nachgebessert: fehlender Klassenkommentar ergänzt
