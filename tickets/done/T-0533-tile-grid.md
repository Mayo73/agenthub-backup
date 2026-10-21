---
id: T-0533
title: TileGrid – Kachelraster für 2D-Level
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Lastenheft: 2D-Level aufbauen): Ein Raster aus Kacheln, in das man Kachelarten setzt, das zwischen Welt- und Rasterkoordinaten umrechnet und sich speichern lässt. Reine Logik ohne `TileMap`-Node.

## Dateien
- `core/tile_grid.gd` – neu, Klasse `TileGrid`
- `tests/test_tile_grid.gd` – neu

## Akzeptanzkriterien
`class_name TileGrid`, `extends RefCounted`.
- `var cell_size := 1.0` (Meter je Kachel), `var cells: Dictionary = {}` (Schlüssel `Vector2i` → Kachelart als `String`)
- `func _init(size: float = 1.0) -> void`
- `func set_cell(cell: Vector2i, kind: String) -> void`: leerer `kind` entfernt die Kachel; `func get_cell(cell: Vector2i) -> String` (leer, wenn keine)
- `func world_to_cell(p: Vector2) -> Vector2i`: `Vector2i(floori(p.x / cell_size), floori(p.y / cell_size))`; `func cell_to_world(cell: Vector2i) -> Vector2`: Mittelpunkt der Kachel
- `func fill_rect(from: Vector2i, to: Vector2i, kind: String) -> int`: alle Zellen im Rechteck einschließlich beider Ecken setzen (Reihenfolge der Ecken egal), Anzahl zurückgeben
- `func count(kind: String) -> int`
- `func used_rect() -> Rect2i`: kleinstes Rechteck um alle Kacheln (`Rect2i()` wenn leer; eine einzelne Kachel ergibt Größe 1×1)
- `func to_dict() -> Dictionary`: `{"cell_size": cell_size, "cells": ["x,y,art", …]}` sortiert; `static func from_dict(d: Dictionary) -> TileGrid` (Zahlen mit `int(...)` bzw. `float(...)`)

## Tests
`tests/test_tile_grid.gd`:
- `test_setzen`: `set_cell(Vector2i(2, 3), "gras")` → `get_cell` „gras“; `set_cell(Vector2i(2, 3), "")` → leer
- `test_umrechnen`: `TileGrid.new(0.5)`: `world_to_cell(Vector2(1.2, -0.1))` ist `Vector2i(2, -1)`, `cell_to_world(Vector2i(2, -1))` ist `Vector2(1.25, -0.25)`
- `test_rechteck`: `fill_rect(Vector2i(3, 1), Vector2i(0, 0), "stein")` → 8, `count("stein")` 8
- `test_bereich`: Kacheln bei (−1, 0) und (2, 4) → `used_rect()` ist `Rect2i(-1, 0, 4, 5)`; leeres Raster → `Rect2i()`
- `test_speichern`: zwei Kacheln, `from_dict(to_dict())` → gleiche `get_cell`-Werte und `cell_size`

Review (21.10.2026): gemergt, nachgebessert: überflüssigen Setter an cell_size entfernt.
