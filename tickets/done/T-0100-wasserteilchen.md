---
id: T-0100
title: Schwebeteilchen in drei Tiefenebenen
project: zellenphase
priority: 5
after: T-0099
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Hinter dem Spielgeschehen schweben kleine Teilchen in drei Tiefenebenen. Hintere Ebenen bewegen sich langsamer mit der Kamera (Parallaxe), so wirkt das Wasser räumlich.

## Dateien
- `scripts/parallax_dots.gd`: neu
- `scripts/water_backdrop.gd`: neu
- `scripts/main.gd`
- `tests/test_parallax_dots.gd`: neu
- `tests/test_main_wiring.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `scripts/parallax_dots.gd` genau so:
```gdscript
class_name ParallaxDots
extends RefCounted
## Schwebeteilchen in mehreren Tiefenebenen. Hintere Ebenen folgen der Kamera langsamer.

const LAYER_FACTORS := [0.2, 0.45, 0.75]
const TILE := 1024.0

## Je Ebene ein PackedVector2Array mit Punkten in [0, TILE)
var layers: Array = []


func _init(points_per_layer: int = 60, seed_value: int = 3) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for factor in LAYER_FACTORS:
		var points := PackedVector2Array()
		for i in points_per_layer:
			points.append(Vector2(rng.randf() * TILE, rng.randf() * TILE))
		layers.append(points)


## Verschiebung einer Ebene bei Kameraposition camera_pos, auf die Kachel gefaltet (0 bis unter TILE).
static func layer_offset(camera_pos: Vector2, factor: float) -> Vector2:
	var offset := -camera_pos * factor
	return Vector2(fposmod(offset.x, TILE), fposmod(offset.y, TILE))
```
- `scripts/water_backdrop.gd` genau so:
```gdscript
class_name WaterBackdrop
extends Node2D
## Zeichnet die Schwebeteilchen über den ganzen Bildschirm, gekachelt.

var dots := ParallaxDots.new()
var camera: Camera2D


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if camera == null:
		return
	var screen := get_viewport_rect().size
	var zoom := camera.zoom.x
	var top_left := camera.position - screen * 0.5 / zoom
	for i in dots.layers.size():
		var offset := ParallaxDots.layer_offset(camera.position, ParallaxDots.LAYER_FACTORS[i])
		var color := Color(0.75, 0.95, 1.0, 0.08 + 0.1 * i)
		var size := 1.5 + 1.5 * i
		for p in dots.layers[i]:
			var x := fposmod(p.x + offset.x, ParallaxDots.TILE)
			while x < screen.x:
				var y := fposmod(p.y + offset.y, ParallaxDots.TILE)
				while y < screen.y:
					draw_circle(top_left + Vector2(x, y) / zoom, size / zoom, color)
					y += ParallaxDots.TILE
				x += ParallaxDots.TILE
```
- `scripts/main.gd`: neue Variable unter `var deaths := 0`: `var backdrop: WaterBackdrop`. In `_ready()` am Ende:
```gdscript
	backdrop = WaterBackdrop.new()
	backdrop.name = "Backdrop"
	backdrop.camera = camera
	world.add_child(backdrop)
	world.move_child(backdrop, 0)
```

## Tests
- `tests/test_parallax_dots.gd` mit `extends "res://tests/base_test.gd"`:
  - `test_ebenen`: `ParallaxDots.new()` → `layers.size()` ist 3, jede Ebene hat 60 Punkte, alle Koordinaten ≥ 0 und < 1024
  - `test_reproduzierbar`: zwei `ParallaxDots.new(10, 4)` → `layers[1][3]` ist bei beiden gleich
  - `test_verschiebung`: `ParallaxDots.layer_offset(Vector2(100, 0), 0.5)` ist (974, 0); `layer_offset(Vector2(-2058, 0), 1.0)` ist (10, 0); `layer_offset(Vector2.ZERO, 0.75)` ist (0, 0)
- `tests/test_main_wiring.gd`, neue Methode `test_hintergrund`: `main.backdrop is WaterBackdrop` wahr; `main.backdrop.get_index()` ist 0; `main.backdrop.camera == main.camera` wahr

Review (16.10.2026): gemergt, nachgebessert: Hintergrund mit move_child(backdrop, 0) ganz nach unten gelegt (fehlte, weil der Test der Nahrung Index 0 verlangte; Nahrung jetzt Index 1).
