---
id: T-0007
title: Reifenspuren im Spiel zeichnen
project: drift
priority: 3
after: T-0006
---
## Ziel
Beim Driften ziehen die beiden Hinterräder dunkle Spuren auf die Strecke. Ein neuer Node `SkidMarks` sammelt die Spuren mit zwei `SkidTrail` (aus T-0006) und zeichnet sie. Er liegt unter `World`, also in Weltkoordinaten, über der Strecke und unter dem Auto.

## Dateien
- `scripts/skid_marks.gd`: neu, `extends Node2D` (ohne `class_name`)
- `scripts/main.gd`: `SkidMarks` anlegen und jeden Physik-Frame aktualisieren
- `tests/test_skid_marks.gd`: neu
- `scenes/main.tscn` **nicht** ändern, der Node wird im Code angelegt.

## Akzeptanzkriterien
- In `scripts/skid_marks.gd`:
  - Konstanten: `const REAR_OFFSET := 22.0` (Abstand Hinterachse hinter der Fahrzeugmitte, px), `const HALF_TRACK := 11.0` (halbe Spurbreite, px), `const LINE_WIDTH := 5.0`, `const LINE_COLOR := Color(0.06, 0.06, 0.07, 0.55)`
  - Variablen: `var left := SkidTrail.new()` und `var right := SkidTrail.new()`
  - `func track_car(car: CarPhysics) -> void`:
    ```gdscript
    var back := car.position - car.forward() * REAR_OFFSET
    var side := car.right() * HALF_TRACK
    var marking := car.is_drifting()
    left.update(back - side, marking)
    right.update(back + side, marking)
    queue_redraw()
    ```
  - `func _draw() -> void`: Für jede Spur in `left.trails` und `right.trails` mit mindestens 2 Punkten `draw_polyline(trail, LINE_COLOR, LINE_WIDTH)`.
- In `scripts/main.gd`:
  - Neue Variable `var skid_marks: Node2D`
  - Am Ende von `_ready()`:
    ```gdscript
    skid_marks = preload("res://scripts/skid_marks.gd").new()
    skid_marks.name = "SkidMarks"
    world.add_child(skid_marks)
    world.move_child(skid_marks, car.get_index())
    ```
  - In `_physics_process(delta)` als letzte Zeile: `skid_marks.track_car(car.physics)`

## Tests
Neue Datei `tests/test_skid_marks.gd` mit `extends "res://tests/base_test.gd"`:
- `test_drift_zieht_spuren`: `var marks: Node2D = preload("res://scripts/skid_marks.gd").new()`, `var car := CarPhysics.new()`, `car.velocity = Vector2(600, 0)`, `car.steer = 1.0`, `car.handbrake = true`. 30-mal: `car.step(1.0 / 60.0)` und `marks.track_car(car)`. → `marks.left.point_count()` ist größer als 2 und `marks.right.point_count()` ist größer als 2. Am Ende `marks.free()`.
- `test_geradeaus_keine_spuren`: wie oben, aber nur `car.throttle = 1.0` (kein Lenken, keine Handbremse) → `marks.left.point_count()` ist 0. Am Ende `marks.free()`.
- `test_spuren_liegen_unter_dem_auto`:
  ```gdscript
  var main: Node = load("res://scenes/main.tscn").instantiate()
  (Engine.get_main_loop() as SceneTree).root.add_child(main)
  var marks := main.get_node("World/SkidMarks")
  check(marks != null, "World/SkidMarks existiert")
  check(marks.get_index() < main.get_node("World/Car").get_index(), "Spuren werden vor dem Auto gezeichnet")
  check(marks.get_index() > main.get_node("World/Track").get_index(), "Spuren liegen über der Strecke")
  main.free()
  ```

Review (15.10.2026): gemergt.
