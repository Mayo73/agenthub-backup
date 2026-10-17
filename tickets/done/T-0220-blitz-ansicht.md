---
id: T-0220
title: Blitze nach einer Entladung kurz zeichnen (ZapView)
project: zellenphase
priority: 2
after: T-0219
---
## Ziel
Eine Ansicht, die nach einer Entladung des Elektroorgans für kurze Zeit Blitze vom Organ zu den getroffenen Zellen zeichnet.

## Dateien
- `scripts/zap_view.gd` – neu
- `tests/test_zap_view.gd` – neu

## Akzeptanzkriterien
`scripts/zap_view.gd` genau so:
```gdscript
class_name ZapView
extends Node2D
## Zeichnet nach einer Entladung kurz aufleuchtende Blitze (ElectricArcs).

const COLOR := Color(0.6, 0.9, 1.0)
const DURATION := 0.2

var lines: Array[PackedVector2Array] = []
var time_left := 0.0
var _seed := 1


## Je ein Blitz von from zu jedem Punkt in targets; ersetzt die bisherigen Blitze.
func show_zaps(from: Vector2, targets: Array[Vector2]) -> void:
	lines.clear()
	for t in targets:
		_seed += 1
		lines.append(ElectricArcs.arc(from, t, 6, 6.0, _seed))
	time_left = DURATION


func tick(delta: float) -> void:
	time_left = maxf(0.0, time_left - delta)
	if time_left <= 0.0:
		lines.clear()


func is_zap_visible() -> bool:
	return time_left > 0.0 and not lines.is_empty()


func _process(delta: float) -> void:
	tick(delta)
	queue_redraw()


func _draw() -> void:
	var c := COLOR
	c.a = clampf(time_left / DURATION, 0.0, 1.0)
	for l in lines:
		draw_polyline(l, c, 2.0)
```
- Keine andere Datei ändern.

## Tests
`tests/test_zap_view.gd` mit `extends "res://tests/base_test.gd"`; jeder Test legt `var v := ZapView.new()` an und ruft am Ende `v.free()` auf:
- `test_zwei_blitze`: `var ziele: Array[Vector2] = [Vector2(100, 0), Vector2(0, 100)]`, `v.show_zaps(Vector2.ZERO, ziele)` → `v.lines.size()` ist 2; `v.lines[0][0]` ist `Vector2.ZERO`; `v.lines[0][6]` ist `Vector2(100, 0)`; `v.lines[1][6]` ist `Vector2(0, 100)`; `v.is_zap_visible()` wahr
- `test_verblasst`: `var ziele: Array[Vector2] = [Vector2(50, 0)]`, `v.show_zaps(Vector2.ZERO, ziele)`, `v.tick(0.1)` → `v.is_zap_visible()` wahr; `v.tick(0.2)` → `v.is_zap_visible()` falsch; `v.lines.size()` ist 0
- `test_anfangs_leer`: `v.is_zap_visible()` falsch

Review (17.10.2026): gemergt.
