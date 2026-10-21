---
id: T-0547
title: Friction – Reibung beim Gleiten in 2D und 3D
project: hub-engine
priority: 4
---
## Ziel
Muss 5 „Physik“: Reibung. Rechnet aus, wie stark ein Körper auf einer Fläche abbremst, ohne den Anteil senkrecht zur Fläche zu ändern.

## Dateien
- `core/friction.gd` – neu, Klasse `Friction`
- `tests/test_friction.gd` – neu

## Akzeptanzkriterien
`class_name Friction`, `extends RefCounted`, nur statische Funktionen.
- `static func combine(a: float, b: float) -> float`: `sqrt(maxf(a, 0.0) * maxf(b, 0.0))`
- `static func slide(velocity: Vector2, normal: Vector2, mu: float, gravity: float, dt: float) -> Vector2`: `n = normal.normalized()`, senkrechter Anteil `vn = n * velocity.dot(n)`, tangentialer Anteil `vt = velocity - vn`, Abbremsung `drop = mu * gravity * dt`; ist `vt.length() <= drop` → `vt = Vector2.ZERO`, sonst `vt -= vt.normalized() * drop`; Ergebnis `vn + vt`
- `static func slide_3d(velocity: Vector3, normal: Vector3, mu: float, gravity: float, dt: float) -> Vector3`: genauso mit `Vector3`
- `static func stop_distance(speed: float, mu: float, gravity: float) -> float`: `mu * gravity <= 0` → `INF`; sonst `speed * speed / (2.0 * mu * gravity)`

## Tests
`tests/test_friction.gd`:
- `test_kombinieren`: `combine(0.5, 0.5)` 0.5, `combine(1.0, 0.0)` 0.0
- `test_bremsen`: `slide(Vector2(2, 0), Vector2(0, -1), 0.5, 9.81, 0.1)` → `x` ungefähr 1.5095, `y` 0.0
- `test_stehen`: `slide(Vector2(0.1, 0), Vector2(0, -1), 0.5, 9.81, 0.1)` ist `Vector2.ZERO`
- `test_normal_bleibt`: `slide(Vector2(2, 3), Vector2(0, -1), 0.5, 9.81, 0.1).y` 3.0
- `test_3d`: `slide_3d(Vector3(0, 0, -2), Vector3.UP, 0.5, 9.81, 0.1).z` ungefähr −1.5095
- `test_bremsweg`: `stop_distance(10.0, 0.5, 9.81)` ungefähr 10.194 (`absf(wert - 10.194) < 0.01`); `is_inf(stop_distance(10.0, 0.0, 9.81))` wahr

Review (21.10.2026): gemergt.
