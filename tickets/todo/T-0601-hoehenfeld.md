---
id: T-0601
title: HeightField – Geländehöhe aus einem Raster
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“: Einfaches Gelände als Höhenraster; die Höhe zwischen den Rasterpunkten wird bilinear interpoliert, damit Figuren auf dem Gelände stehen können.

## Dateien
- `core/height_field.gd` – neu, Klasse `HeightField`
- `tests/test_height_field.gd` – neu

## Akzeptanzkriterien
`class_name HeightField`, `extends RefCounted`. Alle lokalen Variablen mit Typ.
- `var size := Vector2i(2, 2)` (Rasterpunkte in x und z), `var cell := 1.0` (Abstand der Punkte), `var heights: Array[float] = []`
- `func _init(points: Vector2i = Vector2i(2, 2), cell_size: float = 1.0) -> void`: `size = points`, `cell = cell_size`, `heights` mit `points.x * points.y` Nullen füllen
- `func set_height(ix: int, iz: int, h: float) -> void`: außerhalb des Rasters nichts tun; Index `iz * size.x + ix`
- `func get_height(ix: int, iz: int) -> float`: außerhalb → 0.0
- `func height_at(x: float, z: float) -> float`: `var gx: float = clampf(x / cell, 0.0, size.x - 1)`, `var gz: float = clampf(z / cell, 0.0, size.y - 1)`; `var x0: int = mini(int(floor(gx)), size.x - 2)`, `var z0: int = mini(int(floor(gz)), size.y - 2)`; `fx = gx - x0`, `fz = gz - z0`; Ergebnis `lerpf(lerpf(h(x0, z0), h(x0 + 1, z0), fx), lerpf(h(x0, z0 + 1), h(x0 + 1, z0 + 1), fx), fz)` mit `h = get_height`
- `func is_above(p: Vector3) -> bool`: `p.y > height_at(p.x, p.z)`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq` (Zahlen vergleicht `check_eq` ungefähr). Kein `assert`, kein `print`. Einrückung nur mit Tabs.

## Tests
`tests/test_height_field.gd`, jeweils `HeightField.new(Vector2i(3, 3), 2.0)` mit `set_height(1, 1, 4.0)`:
- `test_punkt`: `height_at(2.0, 2.0)` 4.0; `get_height(1, 1)` 4.0; `get_height(5, 0)` 0.0
- `test_zwischen`: `height_at(1.0, 2.0)` 2.0; `height_at(1.0, 1.0)` 1.0
- `test_rand`: `height_at(-5.0, 2.0)` 0.0; `height_at(4.0, 4.0)` 0.0
- `test_ueber`: `is_above(Vector3(2, 5, 2))` wahr, `is_above(Vector3(2, 3, 2))` falsch
