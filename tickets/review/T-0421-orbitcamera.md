---
id: T-0421
title: OrbitCamera – Kameraposition um ein Ziel aus Gieren, Neigen und Abstand
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Muss 3: Kameras in 3D): Die Kamera der 3D-Ansicht kreist um ein Ziel. Die Rechnung als prüfbare Kernlogik, damit Editor und Agenten dieselben Werte nutzen.

## Dateien
- `core/orbit_camera.gd` – neu, Klasse `OrbitCamera`
- `tests/test_orbit_camera.gd` – neu

## Akzeptanzkriterien
`class_name OrbitCamera`, `extends RefCounted`. Winkel in Grad. Gieren (`yaw`) 0 heißt: Kamera auf der +z-Seite des Ziels; positives Gieren dreht gegen den Uhrzeigersinn von oben gesehen (Richtung +x). Neigen (`pitch`) positiv heißt: Kamera über dem Ziel.
- `var target := Vector3.ZERO`, `var yaw := 0.0`, `var pitch := 20.0`, `var distance := 6.0`
- `const MIN_PITCH := -89.0`, `const MAX_PITCH := 89.0`, `const MIN_DISTANCE := 0.5`, `const MAX_DISTANCE := 500.0`
- `func position() -> Vector3`: `target + Vector3(sin(y) * cos(p), sin(p), cos(y) * cos(p)) * distance` mit `y = deg_to_rad(yaw)`, `p = deg_to_rad(pitch)`
- `func orbit(d_yaw: float, d_pitch: float) -> void`: `yaw = fposmod(yaw + d_yaw, 360.0)`, `pitch` mit `clampf` auf die Grenzen
- `func zoom(factor: float) -> void`: `factor <= 0` ignorieren; `distance = clampf(distance * factor, MIN_DISTANCE, MAX_DISTANCE)`
- `func pan(offset: Vector3) -> void`: `target += offset`
- `func to_dict() -> Dictionary` (`target` als `[x, y, z]`) und `static func from_dict(d: Dictionary) -> OrbitCamera` (fehlende Werte behalten den Standard)

## Tests
`tests/test_orbit_camera.gd`, `cam = OrbitCamera.new()`:
- `test_vorne`: `pitch = 0.0` → `position()` ungefähr `Vector3(0, 0, 6)` (je Achse `check_eq`)
- `test_seite`: `pitch = 0.0`, `yaw = 90.0` → ungefähr `Vector3(6, 0, 0)`
- `test_oben`: `pitch = 89.0` → `position().y` größer als 5.99
- `test_grenzen`: `orbit(0, 500)` → `pitch` 89.0; `orbit(400, 0)` → `yaw` 40.0; `zoom(1000.0)` → `distance` 500.0; `zoom(-1.0)` ändert nichts
- `test_ziel`: `pan(Vector3(1, 2, 3))`, `pitch = 0.0` → `position()` ungefähr `Vector3(1, 2, 9)`
- `test_speichern`: `yaw = 45.0`, `OrbitCamera.from_dict(cam.to_dict()).yaw` 45.0
