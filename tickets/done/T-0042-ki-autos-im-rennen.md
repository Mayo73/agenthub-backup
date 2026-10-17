---
id: T-0042
title: Drei KI-Gegner in der Rennszene
project: drift
priority: 3
after: T-0036, T-0041
---
## Ziel
In der Rennszene stehen drei KI-Autos hinter dem Spieler in der Startaufstellung. Sie fahren los, sobald der Countdown vorbei ist, und stehen nach einem Neustart wieder am Start.

## Dateien
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Konstanten in `main.gd`:
  ```gdscript
  ## KI-Gegner: Farben und Tempo-Faktoren, ein Eintrag je Auto.
  const AI_COLORS := [Color(0.55, 0.3, 0.8), Color(0.2, 0.75, 0.75), Color(0.95, 0.5, 0.15)]
  const AI_SKILLS := [0.84, 0.88, 0.92]
  ```
- Neue Variable `var ai_cars: Array[Node2D] = []`
- Am Ende von `_ready()`:
  ```gdscript
  	for i in AI_COLORS.size():
  		var ai: Node2D = preload("res://scripts/ai_car.gd").new()
  		ai.name = "Ai%d" % (i + 1)
  		ai.color = AI_COLORS[i]
  		ai.driver.skill = AI_SKILLS[i]
  		ai.track = track.path
  		world.add_child(ai)
  		ai_cars.append(ai)
  	place_ai_cars()
  ```
- Neue Funktion:
  ```gdscript
  ## Startaufstellung: KI-Autos versetzt hinter dem Spieler.
  func place_ai_cars() -> void:
  	var start := track.path.start_position()
  	var heading := track.path.start_heading()
  	var forward := Vector2.from_angle(heading)
  	var right := Vector2.from_angle(heading + PI / 2.0)
  	for i in ai_cars.size():
  		var side := 70.0 if i % 2 == 0 else -70.0
  		ai_cars[i].place_at(start - forward * 90.0 * (i + 1) + right * side, heading)
  ```
- In `_physics_process` direkt nach `car.input_enabled = race.can_drive()`:
  ```gdscript
  	for ai in ai_cars:
  		ai.driving_enabled = race.can_drive()
  ```
- In `restart()` am Ende `place_ai_cars()`
- Sonst nichts an `main.gd` ändern.

## Tests
In `tests/test_main_wiring.gd` neue Methode `test_ki_gegner` anhängen:
- `main.ai_cars.size()` ist 3, `main.get_node("World/Ai1") != null` ist wahr
- jedes `ai` in `main.ai_cars`: `ai.track == main.track.path` ist wahr, `ai.driving_enabled` ist falsch, `ai.physics.position.distance_to(main.car.physics.position) > 50.0`
- `main.ai_cars[0].physics.position.distance_to(main.ai_cars[1].physics.position) > 50.0`
- `main.ai_cars[0].place_at(Vector2(5000, 5000), 0.0)`, `main.restart()` → `main.ai_cars[0].physics.position.distance_to(main.track.path.start_position()) < 200.0`

Review (16.10.2026): gemergt.
