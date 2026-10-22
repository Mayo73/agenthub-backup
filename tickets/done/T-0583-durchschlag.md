---
id: T-0583
title: Penetration – Durchschlag durch Material
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Ballistik): Projektile verlieren beim Durchschlagen von Material Geschwindigkeit und richten danach weniger Schaden an.

## Dateien
- `core/penetration.gd` – neu, Klasse `Penetration`
- `tests/test_penetration.gd` – neu

## Akzeptanzkriterien
`class_name Penetration`, `extends RefCounted`, nur statische Funktionen.
- `static func exit_speed(speed: float, thickness: float, resistance: float) -> float`: `maxf(speed - thickness * resistance, 0.0)`
- `static func passes(speed: float, thickness: float, resistance: float) -> bool`: `exit_speed(speed, thickness, resistance) > 0.0`
- `static func damage_factor(entry_speed: float, exit_speed_value: float) -> float`: `entry_speed <= 0` → 0.0; sonst `clampf(exit_speed_value / entry_speed, 0.0, 1.0)`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq` (Zahlen vergleicht `check_eq` ungefähr). Einrückung nur mit Tabs.

## Tests
`tests/test_penetration.gd`:
- `test_durch`: `exit_speed(300.0, 0.1, 1000.0)` ist 200.0; `passes(300.0, 0.1, 1000.0)` ist wahr
- `test_stecken`: `exit_speed(50.0, 0.1, 1000.0)` ist 0.0; `passes(50.0, 0.1, 1000.0)` ist falsch
- `test_schaden`: `damage_factor(300.0, 200.0)` liegt weniger als 0.001 von 0.6667 entfernt; `damage_factor(0.0, 10.0)` ist 0.0; `damage_factor(100.0, 150.0)` ist 1.0

Review (21.10.2026): gemergt.
