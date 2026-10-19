---
id: T-0380
title: Ballistics – analytische Flugbahn und Simulation mit 120 Schritten pro Sekunde
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Ballistik und Testeingaben“ (Lastenheft Muss 6, Abnahmekriterium 7): Flugbahnen in 2D und 3D berechnen und mit der analytischen Bahn vergleichen. Höchstens 2 simulierte Sekunden bei 120 Hz, Abweichung höchstens 0,15 Einheiten.

## Dateien
- `core/ballistics.gd` – neu, Klasse `Ballistics`
- `tests/test_ballistics.gd` – neu

## Akzeptanzkriterien
`class_name Ballistics`, `extends RefCounted`, nur statische Funktionen. 1 Einheit = 1 Meter; Schwerkraft wirkt in 2D nach **+y**, in 3D nach **−y**.
- `const GRAVITY := 9.81`, `const HZ := 120`
- `static func position_2d(start: Vector2, velocity: Vector2, t: float, gravity: float = GRAVITY) -> Vector2`: `start + velocity * t + Vector2(0, gravity) * 0.5 * t * t`
- `static func position_3d(start: Vector3, velocity: Vector3, t: float, gravity: float = GRAVITY) -> Vector3`: mit `Vector3(0, -gravity, 0)`
- `static func simulate_2d(start: Vector2, velocity: Vector2, duration: float, hz: int = HZ, gravity: float = GRAVITY) -> PackedVector2Array`: Punkte ab `start`; `steps = roundi(duration * hz)` Schritte mit `dt = 1.0 / hz`; je Schritt `p += v * dt + a * 0.5 * dt * dt`, dann `v += a * dt` → `steps + 1` Punkte
- `static func simulate_3d(start: Vector3, velocity: Vector3, duration: float, hz: int = HZ, gravity: float = GRAVITY) -> PackedVector3Array` genauso
- `static func max_error_2d(points: PackedVector2Array, start: Vector2, velocity: Vector2, hz: int = HZ, gravity: float = GRAVITY) -> float`: größter Abstand zwischen `points[i]` und `position_2d(start, velocity, i / float(hz), gravity)`
- `static func max_error_3d(points: PackedVector3Array, start: Vector3, velocity: Vector3, hz: int = HZ, gravity: float = GRAVITY) -> float` genauso
- `static func time_to_height_2d(start_y: float, velocity_y: float, target_y: float, gravity: float = GRAVITY) -> float`: späterer Zeitpunkt, an dem `y(t) = start_y + velocity_y * t + 0.5 * gravity * t * t` gleich `target_y` ist (größere Lösung der quadratischen Gleichung); `-1.0`, wenn es keine Lösung mit `t >= 0` gibt

## Tests
`tests/test_ballistics.gd`:
- `test_position_2d`: `position_2d(Vector2.ZERO, Vector2(10, -10), 1.0)` → x 10, y -5.095 (je `check_eq`)
- `test_position_3d`: `position_3d(Vector3.ZERO, Vector3(0, 10, 5), 1.0)` → y 5.095, z 5
- `test_simulation_punkte`: `simulate_2d(Vector2.ZERO, Vector2(20, -15), 2.0).size()` 241
- `test_abweichung_2d`: Simulation über 2 s, Start (0, 0), Geschwindigkeit (20, -15) → `max_error_2d(...) < 0.15`
- `test_abweichung_3d`: 2 s, Start (0, 1, 0), Geschwindigkeit (5, 12, -3) → `max_error_3d(...) < 0.15`
- `test_ende_wie_analytisch`: letzter Punkt von `simulate_3d` über 2 s liegt weniger als 0.15 von `position_3d(..., 2.0)` entfernt
- `test_landezeit`: `time_to_height_2d(0.0, -10.0, 0.0)` ≈ 2.0387 (Toleranz 0.001, 20 / 9.81); `time_to_height_2d(0.0, -10.0, -100.0)` -1.0

Review (19.10.2026): gemergt.
