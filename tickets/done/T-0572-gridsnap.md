---
id: T-0572
title: GridSnap – Einrasten von Position und Winkel
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich“ (Editor): Objekte beim Verschieben und Drehen auf ein Raster einrasten.

## Dateien
- `core/grid_snap.gd` – neu, Klasse `GridSnap`
- `tests/test_grid_snap.gd` – neu

## Akzeptanzkriterien
`class_name GridSnap`, `extends RefCounted`, nur statische Funktionen.
- `static func snap(v: Vector2, step: float) -> Vector2`: `step <= 0` → `v` unverändert; sonst jede Achse `round(wert / step) * step`
- `static func snap_3d(v: Vector3, step: float) -> Vector3`: genauso für drei Achsen
- `static func snap_angle(deg: float, step_deg: float) -> float`: `step_deg <= 0` → `deg`; sonst `fposmod(round(deg / step_deg) * step_deg, 360.0)`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq` (Zahlen vergleicht `check_eq` ungefähr). Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren (`var x: float = …`).

## Tests
`tests/test_grid_snap.gd`:
- `test_2d`: `snap(Vector2(1.26, -0.74), 0.5)` ist `Vector2(1.5, -0.5)`; `snap(Vector2(3.3, 1.0), 0.0)` ist `Vector2(3.3, 1.0)`
- `test_3d`: `snap_3d(Vector3(0.24, 0.26, -0.26), 0.5)` ist `Vector3(0, 0.5, -0.5)`
- `test_winkel`: `snap_angle(52.0, 15.0)` ist 45.0; `snap_angle(-10.0, 15.0)` ist 345.0; `snap_angle(359.0, 15.0)` ist 0.0

Review (21.10.2026): gemergt.
