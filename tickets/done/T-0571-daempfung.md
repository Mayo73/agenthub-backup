---
id: T-0571
title: Damping – lineare und Winkeldämpfung in 2D und 3D
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (einstellbare Physikparameter): Geschwindigkeiten pro Schritt dämpfen, unabhängig von der Schrittweite gleich stark.

## Dateien
- `core/damping.gd` – neu, Klasse `Damping`
- `tests/test_damping.gd` – neu

## Akzeptanzkriterien
`class_name Damping`, `extends RefCounted`, nur statische Funktionen.
- `static func factor(damp: float, dt: float) -> float`: `damp <= 0` → 1.0; sonst `exp(-damp * dt)`
- `static func apply(v: Vector2, damp: float, dt: float) -> Vector2`: `v * factor(damp, dt)`; ist die Länge danach kleiner als 0.001 → `Vector2.ZERO`
- `static func apply_3d(v: Vector3, damp: float, dt: float) -> Vector3`: genauso
- `static func apply_angular(w: float, damp: float, dt: float) -> float`: `w * factor(damp, dt)`, Betrag kleiner 0.001 → 0.0
- `static func half_life(damp: float) -> float`: `damp <= 0` → `INF`; sonst `log(2.0) / damp`

Hinweis Typen: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq` (Zahlen vergleicht `check_eq` ungefähr). Einrückung nur mit Tabs.

## Tests
`tests/test_damping.gd`:
- `test_ohne`: `apply(Vector2(3, 4), 0.0, 0.1)` ist `Vector2(3, 4)`; `factor(-1.0, 1.0)` ist 1.0
- `test_halbwertszeit`: `half_life(2.0)` etwa 0.3466; `apply(Vector2(10, 0), 2.0, half_life(2.0))` etwa `Vector2(5, 0)`
- `test_schrittweite`: `v = Vector2(8, 0)` 120-mal mit `apply(v, 1.0, 1.0 / 120.0)` gedämpft liegt weniger als 0.001 von `apply(Vector2(8, 0), 1.0, 1.0)` entfernt
- `test_ruhe`: `apply_3d(Vector3(0.0005, 0, 0), 1.0, 0.01)` ist `Vector3.ZERO`; `apply_angular(0.0005, 1.0, 0.01)` ist 0.0

Review (21.10.2026): gemergt.
