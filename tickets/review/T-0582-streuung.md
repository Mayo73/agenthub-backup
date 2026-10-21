---
id: T-0582
title: Spread – Streukegel für Schüsse
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Ballistik): Schüsse streuen in einem Kegel um die Zielrichtung, mit festem Seed wiederholbar (wichtig für Tests).

## Dateien
- `core/spread.gd` – neu, Klasse `Spread`
- `tests/test_spread.gd` – neu

## Akzeptanzkriterien
`class_name Spread`, `extends RefCounted`, nur statische Funktionen.
- `static func direction(forward: Vector3, angle_deg: float, seed_value: int) -> Vector3`:
  - `var f: Vector3 = forward.normalized()`; bei `angle_deg <= 0` → `f` zurückgeben
  - `var rng := RandomNumberGenerator.new()`, `rng.seed = seed_value`
  - `var theta: float = deg_to_rad(angle_deg) * sqrt(rng.randf())`, `var phi: float = rng.randf() * TAU`
  - `var up: Vector3 = Vector3.UP if absf(f.dot(Vector3.UP)) < 0.99 else Vector3.RIGHT`
  - `var right: Vector3 = f.cross(up).normalized()`, `var up2: Vector3 = right.cross(f)`
  - Ergebnis: `(f * cos(theta) + (right * cos(phi) + up2 * sin(phi)) * sin(theta)).normalized()`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Vektoren mit `is_equal_approx` vergleichen. Einrückung nur mit Tabs.

## Tests
`tests/test_spread.gd`:
- `test_ohne_streuung`: `direction(Vector3(0, 0, -2), 0.0, 1)` ist etwa `Vector3(0, 0, -1)`
- `test_wiederholbar`: zweimal `direction(Vector3(0, 0, -1), 5.0, 7)` ergibt dasselbe; Seeds 1 und 2 ergeben verschiedene Richtungen
- `test_kegel`: für Seeds 1 bis 50 ist `rad_to_deg(d.angle_to(Vector3(0, 0, -1)))` höchstens 5.001 und `absf(d.length() - 1.0) < 0.001`
- `test_senkrecht`: `direction(Vector3.UP, 3.0, 4)` hat die Länge etwa 1 und höchstens 3.001 Grad Abstand zu `Vector3.UP`
