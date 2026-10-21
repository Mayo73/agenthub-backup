---
id: T-0531
title: FollowCamera3D – Verfolgerkamera hinter einem Ziel
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Lastenheft: Kamerasteuerung für 3D-Spiele): Eine Kamera folgt einem Ziel von hinten oben und holt es weich ein. Reine Rechnung ohne Nodes.

## Dateien
- `core/follow_camera_3d.gd` – neu, Klasse `FollowCamera3D`
- `tests/test_follow_camera_3d.gd` – neu

## Akzeptanzkriterien
`class_name FollowCamera3D`, `extends RefCounted`. Vorher `core/orbit_camera.gd` als Beispiel lesen.
- `var distance := 6.0`, `var height := 2.5`, `var smoothing := 5.0` (je Sekunde; 0 = sofort), `var position := Vector3.ZERO`
- `func desired(target: Vector3, yaw: float) -> Vector3`: Punkt `distance` hinter dem Ziel und `height` darüber. „Vorne“ bei `yaw` ist `Vector3(sin(yaw), 0, -cos(yaw))` (bei `yaw` 0 also −z), Ergebnis `target - vorne * distance + Vector3(0, height, 0)`
- `func snap(target: Vector3, yaw: float) -> void`: `position = desired(...)`
- `func update(target: Vector3, yaw: float, dt: float) -> Vector3`: bei `smoothing <= 0` wie `snap`; sonst `position = position.lerp(desired(...), clampf(smoothing * dt, 0.0, 1.0))`; gibt `position` zurück
- `func look_target(target: Vector3) -> Vector3`: `target + Vector3(0, 1, 0)`

## Tests
`tests/test_follow_camera_3d.gd`:
- `test_hinter_dem_ziel`: `desired(Vector3.ZERO, 0.0)` ist ungefähr `Vector3(0, 2.5, 6)`
- `test_gedreht`: `desired(Vector3.ZERO, PI / 2)` ist ungefähr `Vector3(-6, 2.5, 0)`
- `test_weich`: `snap(Vector3.ZERO, 0.0)`, dann `update(Vector3(0, 0, -10), 0.0, 0.1)` → `position.z` liegt zwischen −4 und 6 (nicht sofort am Ziel); nach 300 weiteren `update`-Aufrufen mit `dt` 0.1 ungefähr −4
- `test_sofort`: `smoothing = 0`, `update(Vector3(5, 0, 0), 0.0, 0.016)` ist ungefähr `Vector3(5, 2.5, 6)`
- `test_blickpunkt`: `look_target(Vector3(1, 0, 2))` ist `Vector3(1, 1, 2)`

Review (21.10.2026): gemergt.
