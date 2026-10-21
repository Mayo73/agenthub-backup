---
id: T-0557
title: DamageFalloff – Schaden nach Entfernung abschwächen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Waffen und Treffer): Schaden je nach Entfernung linear abschwächen und Flächenschaden um einen Einschlag verteilen.

## Dateien
- `core/damage_falloff.gd` – neu, Klasse `DamageFalloff`
- `tests/test_damage_falloff.gd` – neu

## Akzeptanzkriterien
`class_name DamageFalloff`, `extends RefCounted`. Alle lokalen Variablen mit Typ angeben.
- Eigenschaften: `var base: float = 10.0`, `var near: float = 5.0`, `var far: float = 20.0`, `var min_factor: float = 0.25`; `func _init(p_base: float = 10.0, p_near: float = 5.0, p_far: float = 20.0, p_min_factor: float = 0.25) -> void`
- `func factor(distance: float) -> float`: `1.0` bis einschließlich `near`, `min_factor` ab einschließlich `far`, dazwischen linear (`lerpf(1.0, min_factor, (distance - near) / (far - near))`). Ist `far <= near`: `1.0` bis `near`, sonst `min_factor`
- `func amount(distance: float) -> float`: `base * factor(distance)`
- `static func splash(center: Vector3, radius: float, damage: float, positions: Array[Vector3]) -> Array[float]`: für jede Position `damage * (1 - d / radius)` mit `d = center.distance_to(p)`, außerhalb (`d >= radius`) `0.0`; `radius <= 0` → lauter `0.0`. Gleiche Länge und Reihenfolge wie `positions`

## Tests
`tests/test_damage_falloff.gd` beginnt mit `extends "res://tests/base_test.gd"` (wie `tests/test_wind.gd`), Testfunktionen `func test_…() -> void`, Prüfungen mit `check(...)` und `check_eq(...)`, kein `assert` und kein `print`.
- `test_nah_und_fern`: Standardwerte: `amount(2.0)` ist `10.0`, `amount(5.0)` ist `10.0`, `amount(30.0)` ist `2.5`
- `test_mitte`: Standardwerte: `factor(12.5)` ist ungefähr `0.625` (Toleranz 0.0001)
- `test_flaeche`: `splash(Vector3.ZERO, 4.0, 8.0, [Vector3.ZERO, Vector3(2, 0, 0), Vector3(0, 5, 0)])` ergibt `[8.0, 4.0, 0.0]` (die Liste als `var ps: Array[Vector3] = [...]` anlegen)
- `test_ohne_radius`: `splash(Vector3.ZERO, 0.0, 8.0, ps)` mit 2 Positionen ergibt `[0.0, 0.0]`
