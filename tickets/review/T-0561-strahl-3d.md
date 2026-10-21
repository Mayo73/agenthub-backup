---
id: T-0561
title: RayPick3D – Strahl gegen Kugel und Box (Auswahl in der 3D-Ansicht)
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Objekte in der 3D-Ansicht anklicken und auswählen): Abstand eines Strahls zu Kugeln und achsenparallelen Boxen und das nächste getroffene Objekt.

## Dateien
- `core/ray_pick_3d.gd` – neu, Klasse `RayPick3D`
- `tests/test_ray_pick_3d.gd` – neu

## Akzeptanzkriterien
`class_name RayPick3D`, `extends RefCounted`, nur statische Funktionen. Ergebnis -1.0 heißt „kein Treffer“; `dir` wird intern normalisiert.
- `static func ray_sphere(origin: Vector3, dir: Vector3, center: Vector3, radius: float) -> float`: `d = dir.normalized()`, `oc = origin - center`, `b = oc.dot(d)`, `c = oc.dot(oc) - radius * radius`, `disc = b * b - c`; `disc < 0` → -1.0; `t = -b - sqrt(disc)`; ist `t < 0`, dann `t = -b + sqrt(disc)`; ist `t` immer noch `< 0` → -1.0; sonst `t`
- `static func ray_aabb(origin: Vector3, dir: Vector3, box: AABB) -> float`: Slab-Verfahren je Achse (`tmin` = größter Eintritt, `tmax` = kleinster Austritt; ist eine Richtungskomponente 0, muss `origin` auf dieser Achse innerhalb der Box liegen, sonst -1.0); `tmax < maxf(tmin, 0.0)` → -1.0; sonst `maxf(tmin, 0.0)` (Start in der Box → 0.0)
- `static func pick(origin: Vector3, dir: Vector3, targets: Array[Dictionary]) -> Dictionary`: `targets` je `{"id": String, "center": Vector3, "radius": float}` (Kugel) oder `{"id": String, "box": AABB}`; nächster Treffer als `{"id": …, "distance": t}`, ohne Treffer `{}`

Hinweis Typen: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Werte aus Dictionaries immer mit Typ lesen (`var box: AABB = target["box"]`). Einrückung nur mit Tabs.

## Tests
`tests/test_ray_pick_3d.gd`:
- `test_kugel`: `ray_sphere(Vector3.ZERO, Vector3(0, 0, -1), Vector3(0, 0, -10), 2.0)` ist 8.0; seitlich vorbei (`center` `Vector3(5, 0, -10)`) -1.0
- `test_box`: `ray_aabb(Vector3(0, 0, 5), Vector3(0, 0, -1), AABB(Vector3(-1, -1, -1), Vector3(2, 2, 2)))` ist 4.0; Strahl in die andere Richtung -1.0
- `test_innen`: `ray_aabb(Vector3.ZERO, Vector3(1, 0, 0), AABB(Vector3(-1, -1, -1), Vector3(2, 2, 2)))` ist 0.0
- `test_auswahl`: Kugel „a“ bei `Vector3(0, 0, -10)` (Radius 1), Box „b“ `AABB(Vector3(-1, -1, -6), Vector3(2, 2, 2))`, Strahl von `Vector3.ZERO` nach `Vector3(0, 0, -1)` → `id` „b“, `distance` 4.0; Strahl nach `Vector3(0, 1, 0)` → `{}`
