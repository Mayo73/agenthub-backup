---
id: T-0577
title: OneWayPlatform – durchspringbare Plattformen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Spielverhalten, 2D-Referenzspiel): Plattformen, durch die man von unten springt und auf denen man von oben landet; nach unten durchfallen auf Wunsch.

## Dateien
- `core/one_way_platform.gd` – neu, Klasse `OneWayPlatform`
- `tests/test_one_way_platform.gd` – neu

## Akzeptanzkriterien
`class_name OneWayPlatform`, `extends RefCounted`, nur statische Funktionen. y wächst nach unten (wie in Godot 2D).
- `static func blocks(vel_y: float, prev_foot_y: float, foot_y: float, top_y: float, drop: bool = false) -> bool`: wahr genau dann, wenn `not drop`, `vel_y >= 0.0`, `prev_foot_y <= top_y + 0.01` und `foot_y >= top_y`
- `static func in_span(x: float, x_min: float, x_max: float) -> bool`: `x_min <= x <= x_max`
- `static func land(foot_y: float, top_y: float) -> float`: `minf(foot_y, top_y)` (Fuß auf die Oberkante setzen)

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq` (Zahlen vergleicht `check_eq` ungefähr). Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren.

## Tests
`tests/test_one_way_platform.gd`:
- `test_landen`: `blocks(5.0, 9.9, 10.2, 10.0)` ist wahr; `land(10.2, 10.0)` ist 10.0
- `test_von_unten`: `blocks(-5.0, 9.9, 10.2, 10.0)` ist falsch; `blocks(5.0, 10.5, 11.0, 10.0)` ist falsch
- `test_durchfallen`: `blocks(5.0, 9.9, 10.2, 10.0, true)` ist falsch
- `test_breite`: `in_span(3.0, 0.0, 3.0)` ist wahr; `in_span(-0.1, 0.0, 3.0)` ist falsch
