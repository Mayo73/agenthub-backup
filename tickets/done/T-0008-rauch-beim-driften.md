---
id: T-0008
title: Reifenrauch beim Driften
project: drift
priority: 3
after: T-0007
---
## Ziel
Beim Driften steigt hinter dem Auto grauer Reifenrauch auf. Ein `CPUParticles2D` am Heck des Autos sendet nur Partikel aus, solange das Auto driftet.

## Dateien
- `scripts/car.gd`: Rauch im Code anlegen und an- bzw. ausschalten
- `tests/test_car_smoke.gd`: neu
- `scenes/car.tscn` **nicht** ändern.

## Akzeptanzkriterien
- In `scripts/car.gd`:
  - Neue Variable `var smoke: CPUParticles2D`
  - In `_ready()` nach `Controls.setup()` den Rauch anlegen:
    ```gdscript
    smoke = CPUParticles2D.new()
    smoke.name = "Smoke"
    smoke.position = Vector2(-20, 0)
    smoke.emitting = false
    smoke.amount = 40
    smoke.lifetime = 0.9
    smoke.local_coords = false
    smoke.direction = Vector2(-1, 0)
    smoke.spread = 35.0
    smoke.initial_velocity_min = 20.0
    smoke.initial_velocity_max = 60.0
    smoke.gravity = Vector2.ZERO
    smoke.scale_amount_min = 6.0
    smoke.scale_amount_max = 12.0
    smoke.color = Color(0.85, 0.85, 0.85, 0.35)
    add_child(smoke)
    move_child(smoke, 0)
    ```
  - In `_physics_process(delta)` direkt nach `physics.step(delta)`: `smoke.emitting = physics.is_drifting()`

## Tests
Neue Datei `tests/test_car_smoke.gd` mit `extends "res://tests/base_test.gd"`:
- `test_rauch_nur_beim_driften`:
  ```gdscript
  var car: Node2D = load("res://scenes/car.tscn").instantiate()
  (Engine.get_main_loop() as SceneTree).root.add_child(car)
  var smoke := car.get_node("Smoke") as CPUParticles2D
  check(smoke != null, "Car/Smoke existiert")
  check(not smoke.emitting, "im Stand kein Rauch")
  car.physics.velocity = Vector2(600, 0)
  car.physics.sliding = true
  car.physics.heading = 0.6
  car._physics_process(1.0 / 60.0)
  check(smoke.emitting, "im Drift raucht es")
  car.free()
  ```

Review (15.10.2026): gemergt.
