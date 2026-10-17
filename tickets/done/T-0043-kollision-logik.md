---
id: T-0043
title: Zusammenstöße zwischen Autos (CarCollision)
project: drift
priority: 3
---
## Ziel
Autos sollen nicht durcheinander hindurchfahren. Eine Klasse `CarCollision` behandelt zwei Autos als Kreise: Überlappen sie, schiebt sie die beiden auseinander und lässt sie leicht voneinander abprallen.

## Dateien
- `scripts/car_collision.gd`: neu, beginnt mit `class_name CarCollision` und `extends RefCounted`
- `tests/test_car_collision.gd`: neu

## Akzeptanzkriterien
- `const RESTITUTION := 0.3` (wie stark die Autos abprallen, 0 = gar nicht, 1 = voll)
- Funktion:
  ```gdscript
  ## Behandelt zwei Autos als Kreise mit Radius `radius`. Gibt true zurück, wenn sie sich berührt haben.
  static func resolve(a: CarPhysics, b: CarPhysics, radius: float) -> bool:
  	var delta := b.position - a.position
  	var dist := delta.length()
  	var min_dist := radius * 2.0
  	if dist >= min_dist:
  		return false
  	var normal := Vector2.RIGHT if dist < 0.001 else delta / dist
  	var push := (min_dist - dist) * 0.5
  	a.position -= normal * push
  	b.position += normal * push
  	var closing := (b.velocity - a.velocity).dot(normal)
  	if closing < 0.0:
  		var impulse := -(1.0 + RESTITUTION) * closing * 0.5
  		a.velocity -= normal * impulse
  		b.velocity += normal * impulse
  	return true
  ```

## Tests
Neue Datei `tests/test_car_collision.gd` mit `extends "res://tests/base_test.gd"`, Variablen `var a: CarPhysics` und `var b: CarPhysics`, in `setup()` beide mit `CarPhysics.new()` anlegen.
- `test_weit_weg`: `a.position = Vector2(0, 0)`, `b.position = Vector2(100, 0)` → `CarCollision.resolve(a, b, 20.0)` ist falsch, `b.position` ist weiterhin `Vector2(100, 0)`
- `test_auseinanderschieben`: `a.position = Vector2(0, 0)`, `b.position = Vector2(30, 0)` → `resolve(a, b, 20.0)` ist wahr; danach `a.position` ist `Vector2(-5, 0)`, `b.position` ist `Vector2(35, 0)`
- `test_abprallen`: `a.position = Vector2(0, 0)`, `b.position = Vector2(30, 0)`, `a.velocity = Vector2(100, 0)`, `b.velocity = Vector2(-100, 0)`, `resolve(a, b, 20.0)` → `a.velocity` ist `Vector2(-30, 0)`, `b.velocity` ist `Vector2(30, 0)` (jeweils mit `distance_to(…) < 0.01` prüfen)
- `test_auseinanderfahren_kein_abprall`: Positionen wie oben, `a.velocity = Vector2(-50, 0)`, `b.velocity = Vector2(50, 0)`, `resolve(a, b, 20.0)` → Geschwindigkeiten unverändert

Review (16.10.2026): gemergt.
