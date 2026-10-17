---
id: T-0232
title: Riesen in der Tiefe als Schatten zeichnen (DeepGiantView)
project: zellenphase
priority: 3
after: T-0231
---
## Ziel
Eine Ansicht zeichnet die `DeepGiants` als dunkle, halbdurchsichtige, gestreckte Schatten über den ganzen Bildschirm, ähnlich wie `WaterBackdrop` die Schwebeteilchen zeichnet.

## Dateien
- `scripts/deep_giant_view.gd` – neu
- `tests/test_deep_giant_view.gd` – neu

## Akzeptanzkriterien
`scripts/deep_giant_view.gd` genau so:
```gdscript
class_name DeepGiantView
extends Node2D
## Zeichnet die DeepGiants als dunkle, halbdurchsichtige Schatten tief unter der Spielwelt.

const COLOR := Color(0.02, 0.1, 0.16, 0.35)
const POINTS := 24

var giants := DeepGiants.new()
var camera: Camera2D


func _process(delta: float) -> void:
	giants.step(delta)
	queue_redraw()


## Umriss eines Riesen in Bildschirmpixeln: Ellipse aus POINTS Punkten um center,
## in Schwimmrichtung um stretch gestreckt (quer dazu gestaucht) und um heading gedreht.
static func outline(center: Vector2, radius: float, stretch: float, heading: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in POINTS:
		var a := TAU * i / POINTS
		var local := Vector2(cos(a) * radius * stretch, sin(a) * radius / stretch)
		pts.append(center + local.rotated(heading))
	return pts


func _draw() -> void:
	if camera == null:
		return
	var screen := get_viewport_rect().size
	var zoom := camera.zoom.x
	var top_left := camera.position - screen * 0.5 / zoom
	for g: Dictionary in giants.giants:
		var sp := DeepGiants.screen_pos(g["pos"], camera.position, screen)
		var pts := outline(sp, g["radius"], g["stretch"], DeepGiants.heading(g))
		for i in pts.size():
			pts[i] = top_left + pts[i] / zoom
		draw_colored_polygon(pts, COLOR)
```
- Keine andere Datei ändern.

## Tests
`tests/test_deep_giant_view.gd` mit `extends "res://tests/base_test.gd"`:
- `test_umriss`: `var o := DeepGiantView.outline(Vector2.ZERO, 100.0, 1.0, 0.0)` → `o.size()` ist 24; `o[0].is_equal_approx(Vector2(100, 0))` wahr; `o[6].is_equal_approx(Vector2(0, 100))` wahr
- `test_gestreckt`: `var o := DeepGiantView.outline(Vector2(10, 0), 100.0, 2.0, 0.0)` → `o[0].is_equal_approx(Vector2(210, 0))` wahr; `o[6].is_equal_approx(Vector2(10, 50))` wahr
- `test_gedreht`: `var o := DeepGiantView.outline(Vector2.ZERO, 100.0, 1.0, PI / 2.0)` → `o[0].is_equal_approx(Vector2(0, 100))` wahr
- `test_neu`: `var v := DeepGiantView.new()` → `v.giants.giants.size()` ist 3; `v.camera == null` wahr; am Ende `v.free()`
- `test_bewegt`: `var v := DeepGiantView.new()`, `var vor: Vector2 = v.giants.giants[0]["pos"]`, `v._process(1.0)` → `v.giants.giants[0]["pos"] != vor` wahr; am Ende `v.free()`

Review (17.10.2026): gemergt.
