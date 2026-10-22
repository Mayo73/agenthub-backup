---
id: T-0580
title: GridPath – Wegsuche auf einem Raster
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Spielverhalten): Gegner finden auf einem Kachelraster den kürzesten Weg um Hindernisse.

## Dateien
- `core/grid_path.gd` – neu, Klasse `GridPath`
- `tests/test_grid_path.gd` – neu

## Akzeptanzkriterien
`class_name GridPath`, `extends RefCounted`. Breitensuche mit 4 Nachbarn in der festen Reihenfolge `Vector2i(1, 0)`, `Vector2i(0, 1)`, `Vector2i(-1, 0)`, `Vector2i(0, -1)`.
- `var size := Vector2i.ZERO`, `var blocked := {}` (Schlüssel `Vector2i`, Wert `true`)
- `func _init(grid_size: Vector2i = Vector2i.ZERO) -> void`
- `func set_blocked(cell: Vector2i, on: bool = true) -> void`: Eintrag setzen bzw. mit `erase` entfernen
- `func is_free(cell: Vector2i) -> bool`: `0 <= x < size.x`, `0 <= y < size.y` und nicht in `blocked`
- `func find_path(start: Vector2i, goal: Vector2i) -> Array`: Zellen von `start` bis `goal` (beide eingeschlossen). Start oder Ziel nicht frei → `[]`; `start == goal` → `[start]`; unerreichbar → `[]`. Vorgänger in einem Dictionary merken und den Weg am Ende rückwärts zusammensetzen (`reverse()`).

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren (`var cell: Vector2i = …`).

## Tests
`tests/test_grid_path.gd`, jeweils `GridPath.new(Vector2i(5, 5))`:
- `test_gerade`: `find_path(Vector2i(0, 0), Vector2i(2, 0))` ist `[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]`
- `test_umweg`: Wand bei `(1, 0)`, `(1, 1)`, `(1, 2)`, `(1, 3)` → Weg von `(0, 0)` nach `(2, 0)` hat 11 Zellen, beginnt mit `Vector2i(0, 0)`, endet mit `Vector2i(2, 0)` und enthält `Vector2i(1, 4)`
- `test_unerreichbar`: dieselbe Wand und zusätzlich `(1, 4)` → `[]`
- `test_ziel_gesperrt`: `set_blocked(Vector2i(3, 3))` → `find_path(Vector2i(0, 0), Vector2i(3, 3))` ist `[]`; nach `set_blocked(Vector2i(3, 3), false)` nicht leer

Review (21.10.2026): gemergt.
