---
id: T-0039
title: KI-Fahrer (AiDriver)
project: drift
priority: 3
after: T-0038
---
## Ziel
Eine Klasse `AiDriver` setzt die Eingaben (Gas, Bremse, Lenkung) einer `CarPhysics` so, dass das Auto der Strecke folgt: Es zielt auf einen Punkt ein Stück voraus auf der Mittellinie und geht in Kurven vom Gas. Der Algorithmus ist von Claude auf allen drei Strecken erprobt; bitte genau so übernehmen.

## Dateien
- `scripts/ai_driver.gd`: neu, beginnt mit `class_name AiDriver` und `extends RefCounted`
- `tests/test_ai_driver.gd`: neu

## Akzeptanzkriterien
- Konstanten: `const LOOK_AHEAD := 260.0`, `const STEER_GAIN := 2.5`
- `var skill := 0.9` (Tempo-Faktor 0..1, kleiner = langsamer)
- Funktion:
  ```gdscript
  ## Setzt Gas, Bremse und Lenkung so, dass das Auto der Mittellinie von `path` folgt.
  func drive(physics: CarPhysics, path: TrackPath) -> void:
  	var pos := physics.position
  	var target := path.point_at(path.progress_at(pos) + LOOK_AHEAD)
  	var diff := wrapf((target - pos).angle() - physics.heading, -PI, PI)
  	physics.steer = clampf(diff * STEER_GAIN, -1.0, 1.0)
  	var speed_cap: float = physics.max_speed * skill * (1.0 - clampf(absf(diff) * 0.9, 0.0, 0.6))
  	physics.throttle = skill if physics.speed() < speed_cap else 0.0
  	physics.brake = 0.5 if physics.speed() > speed_cap + 120.0 else 0.0
  	physics.handbrake = false
  ```

## Tests
Neue Datei `tests/test_ai_driver.gd` mit `extends "res://tests/base_test.gd"`. Variablen `var driver: AiDriver`, `var path: TrackPath`, `var physics: CarPhysics`; in `setup()`:
```gdscript
	driver = AiDriver.new()
	path = TrackPath.new(PackedVector2Array([Vector2(0, 0), Vector2(2000, 0), Vector2(2000, 2000), Vector2(0, 2000)]), 280.0)
	physics = CarPhysics.new()
	physics.position = Vector2(100, 0)
```
- `test_geradeaus`: `physics.heading = 0.0`, `driver.drive(physics, path)` → `absf(physics.steer) < 0.01`, `physics.throttle` ist 0.9, `physics.brake` ist 0.0
- `test_lenkt_links`: `physics.heading = PI / 2.0` (Auto schaut nach unten, das Ziel liegt links davon), `driver.drive(physics, path)` → `physics.steer` ist -1.0
- `test_lenkt_rechts`: `physics.heading = -PI / 2.0`, `driver.drive(physics, path)` → `physics.steer` ist 1.0
- `test_bremst_wenn_zu_schnell`: `physics.heading = 0.0`, `physics.velocity = Vector2(900, 0)`, `driver.drive(physics, path)` → `physics.throttle` ist 0.0, `physics.brake` ist 0.5

Review (16.10.2026): gemergt.
