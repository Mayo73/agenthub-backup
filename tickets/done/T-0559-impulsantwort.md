---
id: T-0559
title: ImpulseResolve – Stoßantwort zweier Körper in 2D und 3D
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Physik: Masse, Impulse, Rückprall): Nach einem Zusammenstoß zweier Körper die neuen Geschwindigkeiten berechnen.

## Dateien
- `core/impulse_resolve.gd` – neu, Klasse `ImpulseResolve`
- `tests/test_impulse_resolve.gd` – neu

## Akzeptanzkriterien
`class_name ImpulseResolve`, `extends RefCounted`, nur statische Funktionen. Masse `<= 0` bedeutet unbeweglich (statisch, inverse Masse 0).
- `static func inv_mass(m: float) -> float`: `m <= 0` → 0.0, sonst `1.0 / m`
- `static func resolve(v1: Vector2, m1: float, v2: Vector2, m2: float, normal: Vector2, restitution: float) -> Array[Vector2]`: `n = normal.normalized()` (zeigt von Körper 1 zu Körper 2), `rel = (v2 - v1).dot(n)`; ist `rel >= 0` (trennen sich schon) oder `inv_mass(m1) + inv_mass(m2) == 0` → `[v1, v2]` unverändert. Sonst `j = -(1.0 + restitution) * rel / (inv_mass(m1) + inv_mass(m2))`, Ergebnis `[v1 - n * j * inv_mass(m1), v2 + n * j * inv_mass(m2)]`
- `static func resolve_3d(v1: Vector3, m1: float, v2: Vector3, m2: float, normal: Vector3, restitution: float) -> Array[Vector3]`: genauso mit `Vector3`
- `static func impulse_for(mass: float, dv: Vector2) -> Vector2`: `dv * mass` (Impuls, der eine Geschwindigkeitsänderung `dv` bewirkt)

Hinweis Typen: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Ergebnisse in `var result: Array[Vector2] = []` sammeln. Einrückung nur mit Tabs.

## Tests
`tests/test_impulse_resolve.gd`:
- `test_gleiche_massen_elastisch`: `resolve(Vector2(1, 0), 1.0, Vector2(-1, 0), 1.0, Vector2(1, 0), 1.0)` → `[Vector2(-1, 0), Vector2(1, 0)]`
- `test_unelastisch`: `resolve(Vector2(2, 0), 1.0, Vector2.ZERO, 1.0, Vector2(1, 0), 0.0)` → beide `Vector2(1, 0)`
- `test_statische_wand`: `resolve(Vector2(0, 5), 2.0, Vector2.ZERO, 0.0, Vector2(0, 1), 0.5)` → `[Vector2(0, -2.5), Vector2.ZERO]`
- `test_trennen`: `resolve(Vector2(-1, 0), 1.0, Vector2(1, 0), 1.0, Vector2(1, 0), 1.0)` → unverändert
- `test_3d`: `resolve_3d(Vector3(0, -4, 0), 1.0, Vector3.ZERO, 0.0, Vector3(0, -1, 0), 1.0)` → erstes Ergebnis `Vector3(0, 4, 0)`

Review (21.10.2026): gemergt.
