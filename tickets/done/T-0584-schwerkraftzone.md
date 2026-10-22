---
id: T-0584
title: GravityZone3D – Bereiche mit eigener Schwerkraft
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (3D-Physik): Bereiche, in denen eine andere Schwerkraft gilt (Schwerelosigkeit, Auftrieb); bei Überlappung entscheidet die Priorität.

## Dateien
- `core/gravity_zone_3d.gd` – neu, Klasse `GravityZone3D`
- `tests/test_gravity_zone_3d.gd` – neu

## Akzeptanzkriterien
`class_name GravityZone3D`, `extends RefCounted`.
- `var box := AABB()`, `var gravity := Vector3.ZERO`, `var priority := 0`
- `func _init(area: AABB = AABB(), g: Vector3 = Vector3.ZERO, prio: int = 0) -> void`
- `func contains(p: Vector3) -> bool`: `box.has_point(p)`
- `static func gravity_at(zones: Array, p: Vector3, default_g: Vector3) -> Vector3`: unter allen Zonen, die `p` enthalten, die mit der höchsten `priority` (bei Gleichstand die erste in der Liste); keine → `default_g`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Vektoren mit `is_equal_approx` vergleichen. Einrückung nur mit Tabs.

## Tests
`tests/test_gravity_zone_3d.gd`, Standard `Vector3(0, -9.8, 0)`, Zone `a = GravityZone3D.new(AABB(Vector3(0, 0, 0), Vector3(10, 10, 10)), Vector3.ZERO, 0)`, Zone `b = GravityZone3D.new(AABB(Vector3(5, 0, 0), Vector3(10, 10, 10)), Vector3(0, 9.8, 0), 1)`:
- `test_zone`: `gravity_at([a, b], Vector3(1, 1, 1), standard)` ist `Vector3.ZERO`
- `test_prioritaet`: bei `Vector3(6, 1, 1)` ist es `Vector3(0, 9.8, 0)`
- `test_draussen`: bei `Vector3(20, 1, 1)` ist es der Standard
- `test_gleichstand`: `b.priority = 0` → bei `Vector3(6, 1, 1)` gilt `a` (`Vector3.ZERO`)

Review (21.10.2026): gemergt.
