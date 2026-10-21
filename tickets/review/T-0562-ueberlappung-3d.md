---
id: T-0562
title: ShapeOverlap3D – Überlappung von Kugeln und Boxen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Kollisionsformen in 3D): Eindringtiefe und Herausschieben, als Gegenstück zu `ShapeOverlap2D`.

## Dateien
- `core/shape_overlap_3d.gd` – neu, Klasse `ShapeOverlap3D`
- `tests/test_shape_overlap_3d.gd` – neu

## Akzeptanzkriterien
`class_name ShapeOverlap3D`, `extends RefCounted`, nur statische Funktionen. Vorher `core/shape_overlap_2d.gd` lesen.
- `static func spheres(c1: Vector3, r1: float, c2: Vector3, r2: float) -> float`: `r1 + r2 - c1.distance_to(c2)`, wenn größer 0, sonst 0.0
- `static func boxes(a: AABB, b: AABB) -> Vector3`: Überlappung je Achse `ox = minf(a.end.x, b.end.x) - maxf(a.position.x, b.position.x)` (ebenso `oy`, `oz`); eine davon `<= 0` → `Vector3.ZERO`. Sonst entlang der Achse mit der kleinsten Überlappung (bei Gleichheit x vor y vor z), Richtung weg von `b`: negativ, wenn der Mittelpunkt von `a` (`a.get_center()`) auf dieser Achse kleiner ist als der von `b`, sonst positiv
- `static func sphere_box(c: Vector3, r: float, box: AABB) -> float`: nächster Punkt `c.clamp(box.position, box.end)`, `r - c.distance_to(naechster)`, wenn größer 0, sonst 0.0
- `static func point_in_box(p: Vector3, box: AABB) -> bool`: alle drei Koordinaten zwischen `box.position` und `box.end` (Ränder zählen)

Hinweis Typen: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Lokale Variablen mit Typ (`var ox: float = …`). Einrückung nur mit Tabs.

## Tests
`tests/test_shape_overlap_3d.gd`:
- `test_kugeln`: `spheres(Vector3.ZERO, 1.0, Vector3(1.5, 0, 0), 1.0)` ist 0.5; Abstand 3 → 0.0
- `test_boxen`: `boxes(AABB(Vector3(0, 0, 0), Vector3(2, 2, 2)), AABB(Vector3(0, 1.5, 0), Vector3(2, 2, 2)))` ist `Vector3(0, -0.5, 0)`; getrennte Boxen → `Vector3.ZERO`
- `test_gleichstand`: `boxes(AABB(Vector3(1, 1, 1), Vector3(2, 2, 2)), AABB(Vector3.ZERO, Vector3(2, 2, 2)))` ist `Vector3(1, 0, 0)`
- `test_kugel_box`: `sphere_box(Vector3(0, 2.5, 0), 1.0, AABB(Vector3(-1, 0, -1), Vector3(2, 2, 2)))` ist 0.5
- `test_punkt`: `point_in_box(Vector3(2, 2, 2), AABB(Vector3.ZERO, Vector3(2, 2, 2)))` true, `Vector3(2.1, 0, 0)` false
