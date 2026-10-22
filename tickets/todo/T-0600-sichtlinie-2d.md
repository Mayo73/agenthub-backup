---
id: T-0600
title: LineOfSight2D – Sichtlinie gegen Wände prüfen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“: Prüfen, ob ein Gegner den Spieler sehen kann, also ob eine Strecke ein Rechteck (Wand) schneidet.

## Dateien
- `core/line_of_sight_2d.gd` – neu, Klasse `LineOfSight2D`
- `tests/test_line_of_sight_2d.gd` – neu

## Akzeptanzkriterien
`class_name LineOfSight2D`, `extends RefCounted`, nur statische Funktionen. Alle lokalen Variablen mit Typ.
- `static func segment_hits_rect(a: Vector2, b: Vector2, rect: Rect2) -> bool`: Slab-Verfahren auf der Strecke: `var d: Vector2 = b - a`, `var tmin: float = 0.0`, `var tmax: float = 1.0`; für x und y: ist `absf(d[i]) < 0.000000001`, muss `a[i]` zwischen `rect.position[i]` und `rect.end[i]` liegen (Ränder zählen), sonst `false`; andernfalls `t1 = (rect.position[i] - a[i]) / d[i]`, `t2 = (rect.end[i] - a[i]) / d[i]`, bei `t1 > t2` tauschen, `tmin = maxf(tmin, t1)`, `tmax = minf(tmax, t2)`, ist `tmin > tmax` → `false`. Am Ende `true`
- `static func visible(from: Vector2, to: Vector2, walls: Array[Rect2]) -> bool`: keine Wand schneidet die Strecke
- `static func first_blocker(from: Vector2, to: Vector2, walls: Array[Rect2]) -> int`: Index der ersten Wand in der Liste, die schneidet, sonst -1

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs.

## Tests
`tests/test_line_of_sight_2d.gd`, Wand `Rect2(4, -1, 2, 2)`:
- `test_schneidet`: `segment_hits_rect(Vector2(0, 0), Vector2(10, 0), wand)` wahr; `Vector2(0, 5)` nach `Vector2(10, 5)` falsch
- `test_zu_kurz`: `Vector2(0, 0)` nach `Vector2(3, 0)` falsch
- `test_senkrecht`: `Vector2(5, -5)` nach `Vector2(5, 5)` wahr; `Vector2(8, -5)` nach `Vector2(8, 5)` falsch
- `test_sicht`: `var walls: Array[Rect2] = [Rect2(4, 3, 2, 2), wand]` → `visible(Vector2(0, 0), Vector2(10, 0), walls)` falsch, `first_blocker(...)` 1; von `Vector2(0, 10)` nach `Vector2(10, 10)` sichtbar und `first_blocker` -1
