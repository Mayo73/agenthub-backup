---
id: T-0015
title: Geisterauto – Node zum Anzeigen
project: drift
priority: 3
after: T-0014
---
## Ziel
Ein halbdurchsichtiges Auto, das eine `GhostLap` nachfährt. Der Node zeichnet sich selbst als einfaches Rechteck und setzt Position und Drehung aus der Aufnahme. Noch nicht in `main.gd` einbauen.

## Dateien
- `scripts/ghost_car.gd`: neu, `extends Node2D` (ohne `class_name`)
- `tests/test_ghost_car.gd`: neu

## Akzeptanzkriterien
- Konstanten: `const LENGTH := 44.0`, `const WIDTH := 22.0`, `const COLOR := Color(0.75, 0.9, 1.0, 0.35)`
- `func _init() -> void:` setzt `visible = false`
- `func show_at(lap: GhostLap, time: float) -> void`:
  - ist `lap == null` oder `lap.is_empty()`: `visible = false`, sonst nichts
  - sonst `visible = true`, `position = lap.position_at(time)`, `rotation = lap.heading_at(time)`
- `func _draw() -> void`: `draw_rect(Rect2(-LENGTH * 0.5, -WIDTH * 0.5, LENGTH, WIDTH), COLOR)`

## Tests
Neue Datei `tests/test_ghost_car.gd` mit `extends "res://tests/base_test.gd"`. Den Node in jedem Test mit `var ghost: Node2D = preload("res://scripts/ghost_car.gd").new()` anlegen und am Ende `ghost.free()`.
- `test_ohne_aufnahme_unsichtbar`: `ghost.visible` ist falsch; `ghost.show_at(null, 1.0)` → `ghost.visible` falsch; `ghost.show_at(GhostLap.new(), 1.0)` → `ghost.visible` falsch
- `test_folgt_aufnahme`: `var lap := GhostLap.new()`, `lap.record(0.0, Vector2(0, 0), 0.0)`, `lap.record(0.1, Vector2(10, 0), 0.0)`; `ghost.show_at(lap, 0.05)` → `ghost.visible` wahr, `ghost.position.distance_to(Vector2(5, 0)) < 0.01`, `ghost.rotation` ist 0.0

Review (16.10.2026): gemergt.
