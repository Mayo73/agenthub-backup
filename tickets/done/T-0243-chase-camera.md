---
id: T-0243
title: Fischphase – Verfolgerkamera (ChaseCamera)
project: zellenphase
priority: 3
after: T-0241
---
## Ziel
Die Kamera der Fischphase schwebt hinter und etwas über dem Fisch und folgt ihm weich. Sie bleibt immer unter Wasser. Größere Fische sieht sie aus größerem Abstand (Maßstabswechsel wie in der Zellenphase).

## Dateien
- `scripts/chase_camera.gd` – neu
- `tests/test_chase_camera.gd` – neu

## Akzeptanzkriterien
`scripts/chase_camera.gd` genau so:
```gdscript
class_name ChaseCamera
extends RefCounted
## Verfolgerkamera der Fischphase: hinter und etwas über dem Fisch, folgt weich und bleibt unter Wasser.

const DISTANCE := 6.0
const HEIGHT := 1.5
## Je größer, desto schneller holt die Kamera auf.
const FOLLOW := 4.0


## Wunschlage: DISTANCE * size hinter dem Fisch (waagrecht entgegen der Blickrichtung) und HEIGHT * size darüber.
static func target_position(fish_pos: Vector3, yaw: float, size: float = 1.0) -> Vector3:
	var back := -FishMotion.forward_of(yaw, 0.0)
	var p := fish_pos + back * DISTANCE * size + Vector3.UP * HEIGHT * size
	return FishWorld.clamp_to_water(p, 0.3)


## Weiches Folgen: nähert current an target an, unabhängig von der Bildrate.
static func follow(current: Vector3, target: Vector3, delta: float) -> Vector3:
	return current.lerp(target, 1.0 - exp(-FOLLOW * delta))
```
- Keine andere Datei ändern.

## Tests
`tests/test_chase_camera.gd` mit `extends "res://tests/base_test.gd"`:
- `test_hinter_dem_fisch`: `ChaseCamera.target_position(Vector3(0, -20, 0), 0.0).is_equal_approx(Vector3(0, -18.5, 6))` wahr
- `test_gedreht`: `ChaseCamera.target_position(Vector3(0, -20, 0), PI / 2.0).is_equal_approx(Vector3(6, -18.5, 0))` wahr
- `test_groesse`: `ChaseCamera.target_position(Vector3(0, -20, 0), 0.0, 2.0).is_equal_approx(Vector3(0, -17, 12))` wahr
- `test_unter_wasser`: `ChaseCamera.target_position(Vector3(0, -0.5, 0), 0.0).y` ist -0.3
- `test_folgen`: `ChaseCamera.follow(Vector3.ZERO, Vector3(10, 0, 0), 0.0)` ist `Vector3.ZERO`; `ChaseCamera.follow(Vector3.ZERO, Vector3(10, 0, 0), 0.25).x` ist `10.0 * (1.0 - exp(-1.0))`; `ChaseCamera.follow(Vector3.ZERO, Vector3(10, 0, 0), 10.0).is_equal_approx(Vector3(10, 0, 0))` wahr

Review (17.10.2026): gemergt.
