---
id: T-0041
title: KI-Auto als Node (ai_car.gd)
project: drift
priority: 3
after: T-0039
---
## Ziel
Ein Node für ein computergesteuertes Auto: Er rechnet mit `CarPhysics` und `AiDriver`, folgt der Strecke und zeichnet sich als einfaches farbiges Auto. Eingebaut wird er in einem späteren Ticket.

## Dateien
- `scripts/ai_car.gd`: neu
- `tests/test_ai_car.gd`: neu

## Akzeptanzkriterien
- `scripts/ai_car.gd`:
  ```gdscript
  extends Node2D
  ## KI-Gegner: fährt mit AiDriver und CarPhysics, zeichnet sich als einfaches Auto.
  ## Liegt unter "World" und arbeitet in Weltkoordinaten.

  const BODY := [Vector2(-25, -12), Vector2(21, -12), Vector2(26, -7), Vector2(26, 7), Vector2(21, 12), Vector2(-25, 12)]

  var physics := CarPhysics.new()
  var driver := AiDriver.new()
  var track: TrackPath
  var color := Color(0.55, 0.3, 0.8)
  var driving_enabled := false


  func _init() -> void:
  	scale = Vector2(1.3, 1.3)


  ## Setzt das Auto still an eine Stelle.
  func place_at(world_position: Vector2, heading: float) -> void:
  	physics.position = world_position
  	physics.heading = heading
  	physics.velocity = Vector2.ZERO
  	physics.sliding = false
  	position = world_position
  	rotation = heading


  func _physics_process(delta: float) -> void:
  	if track == null:
  		return
  	if driving_enabled:
  		driver.drive(physics, track)
  	else:
  		physics.throttle = 0.0
  		physics.brake = 0.0
  		physics.steer = 0.0
  		physics.handbrake = false
  	physics.surface = CarPhysics.Surface.ROAD if track.is_on_track(physics.position) else CarPhysics.Surface.GRASS
  	physics.step(delta)
  	position = physics.position
  	rotation = physics.heading


  func _draw() -> void:
  	draw_colored_polygon(PackedVector2Array(BODY), color)
  ```

## Tests
Neue Datei `tests/test_ai_car.gd` mit `extends "res://tests/base_test.gd"`. In `setup()`: `ai = preload("res://scripts/ai_car.gd").new()` (Variable `var ai: Node2D`), `ai.track = TrackPath.new(TrackPath.smooth_closed(TrackCatalog.points_of("hafen"), 10), 280.0)`. In `teardown()`: `ai.free()`.
- `test_platzieren`: `ai.place_at(Vector2(10, 20), 0.5)` → `ai.position` ist `Vector2(10, 20)`, `ai.physics.position` ist `Vector2(10, 20)`, `ai.rotation` ist 0.5
- `test_steht_ohne_freigabe`: `ai.place_at(ai.track.start_position(), ai.track.start_heading())`, 30-mal `ai._physics_process(1.0 / 60.0)` → `ai.physics.speed() < 1.0`
- `test_faehrt_mit_freigabe`: wie oben platzieren, `ai.driving_enabled = true`, 60-mal `ai._physics_process(1.0 / 60.0)` → `ai.physics.speed() > 50.0` und `ai.track.is_on_track(ai.physics.position)` ist wahr

Review (16.10.2026): gemergt.
