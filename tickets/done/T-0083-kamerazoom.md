---
id: T-0083
title: Kamera zoomt mit der Zellgröße (CameraZoom)
project: zellenphase
priority: 4
after: T-0082
---
## Ziel
Wie bei Spore zoomt die Kamera heraus, wenn die Zelle wächst, damit der Wechsel des Maßstabs spürbar wird. Der Zoom gleitet weich zum Zielwert.

## Dateien
- `scripts/camera_zoom.gd`: neu
- `scripts/main.gd`
- `tests/test_camera_zoom.gd`: neu
- `tests/test_main_wiring.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `scripts/camera_zoom.gd` genau so:
```gdscript
class_name CameraZoom
extends RefCounted
## Zoom der Kamera passend zur Zellgröße: doppelter Radius = halber Zoom.

const BASE_RADIUS := 12.0
const BASE_ZOOM := 1.6
const MIN_ZOOM := 0.3
const MAX_ZOOM := 2.0


static func target_for_radius(radius: float) -> float:
	return clampf(BASE_ZOOM * BASE_RADIUS / radius, MIN_ZOOM, MAX_ZOOM)


## Gleitet von current Richtung target, unabhängig von der Bildrate.
static func smooth(current: float, target: float, delta: float, rate: float = 2.0) -> float:
	return lerpf(current, target, 1.0 - exp(-rate * delta))
```
- `scripts/main.gd`: in `_ready()` direkt nach `world.add_child(player)`:
  `camera.zoom = Vector2.ONE * CameraZoom.target_for_radius(player.radius)`.
  In `_process` den Parameter von `_delta` in `delta` umbenennen und nach `camera.position = player.position` anhängen:
```gdscript
	var zoom := CameraZoom.smooth(camera.zoom.x, CameraZoom.target_for_radius(player.radius), delta)
	camera.zoom = Vector2(zoom, zoom)
```

## Tests
- `tests/test_camera_zoom.gd` mit `extends "res://tests/base_test.gd"`:
  - `test_ziel`: `CameraZoom.target_for_radius(12.0)` ist 1.6; `(24.0)` ist 0.8; `(6.0)` ist 2.0; `(100.0)` ist 0.3
  - `test_gleiten`: `CameraZoom.smooth(1.0, 0.5, 0.0)` ist 1.0; `CameraZoom.smooth(1.0, 0.5, 100.0)` ist 0.5; `CameraZoom.smooth(1.0, 0.0, 0.5, 2.0)` ist `exp(-1.0)`
- `tests/test_main_wiring.gd`, neue Methode `test_kamera_zoom`: `main.camera.zoom.x` ist 1.6; nach `main.player.radius = 24.0` und `main._process(100.0)` ist `main.camera.zoom.x` gleich 0.8.

Review (16.10.2026): gemergt.
