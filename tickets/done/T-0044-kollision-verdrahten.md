---
id: T-0044
title: Zusammenstöße in der Rennszene
project: drift
priority: 3
after: T-0042, T-0043
---
## Ziel
In der Rennszene stoßen Spieler und KI-Autos aneinander, statt durcheinander hindurchzufahren.

## Dateien
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Konstante in `main.gd`: `const CAR_RADIUS := 24.0`
- Neue Funktion:
  ```gdscript
  ## Alle Autos paarweise auf Zusammenstöße prüfen.
  func resolve_collisions() -> void:
  	var all: Array[CarPhysics] = [car.physics]
  	for ai in ai_cars:
  		all.append(ai.physics)
  	for i in all.size():
  		for j in range(i + 1, all.size()):
  			CarCollision.resolve(all[i], all[j], CAR_RADIUS)
  ```
- In `_physics_process` direkt nach der Schleife, die `ai.driving_enabled` setzt: `resolve_collisions()`
- Sonst nichts an `main.gd` ändern.

## Tests
In `tests/test_main_wiring.gd` neue Methode `test_zusammenstoesse` anhängen:
- `main.car.physics.position = Vector2(0, 0)`, `main.ai_cars[0].physics.position = Vector2(10, 0)`, die anderen KI-Autos mit `physics.position` auf `Vector2(5000, 0)` und `Vector2(-5000, 0)` setzen
- `main.resolve_collisions()` → `main.car.physics.position.distance_to(main.ai_cars[0].physics.position) >= 2.0 * main.CAR_RADIUS - 0.01` ist wahr

Review (16.10.2026): gemergt.
