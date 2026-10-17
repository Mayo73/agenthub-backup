---
id: T-0159
title: Wasserhintergrund als Bild (WaterBackdrop)
project: zellenphase
priority: 3
after: T-0100, A-0007
---
## Ziel
Hinter den Schwebeteilchen liegt jetzt das mit Higgsfield erzeugte Wasserbild `assets/water/wasser_tiefe.png` (1024 × 1024, nahtlos kachelbar). Es folgt der Kamera noch langsamer als die hinterste Teilchenebene, das verstärkt die Tiefenwirkung (Lastenheft „Wasserwelt und Darstellung“).

## Dateien
- `scripts/water_backdrop.gd`
- `tests/test_water_texture.gd`: neu

## Akzeptanzkriterien
In `scripts/water_backdrop.gd`:
- Unter dem Klassenkommentar zwei Konstanten:
```gdscript
const TEXTURE: Texture2D = preload("res://assets/water/wasser_tiefe.png")
## So stark folgt das Wasserbild der Kamera (langsamer als die Teilchen).
const TEXTURE_FACTOR := 0.1
```
- Neue statische Funktion am Ende:
```gdscript
## Linke obere Ecken (Bildschirmpixel) aller Kacheln, die einen Bildschirm der Größe screen bedecken,
## wenn die Kachelung um offset (0 bis unter ParallaxDots.TILE) verschoben ist.
static func tile_origins(screen: Vector2, offset: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	var x := offset.x - ParallaxDots.TILE
	while x < screen.x:
		var y := offset.y - ParallaxDots.TILE
		while y < screen.y:
			out.append(Vector2(x, y))
			y += ParallaxDots.TILE
		x += ParallaxDots.TILE
	return out
```
- In `_draw()` direkt nach der Zeile `var top_left := ...` (vor der Schleife über `dots.layers`) einfügen:
```gdscript
	var tex_offset := ParallaxDots.layer_offset(camera.position, TEXTURE_FACTOR)
	for origin in tile_origins(screen, tex_offset):
		draw_texture_rect(TEXTURE, Rect2(top_left + origin / zoom, Vector2.ONE * ParallaxDots.TILE / zoom), false)
```
- Sonst nichts ändern.

## Tests
`tests/test_water_texture.gd` mit `extends "res://tests/base_test.gd"`:
- `test_bild`: `WaterBackdrop.TEXTURE != null` wahr; `WaterBackdrop.TEXTURE.get_width()` ist 1024
- `test_kacheln`: `var t := WaterBackdrop.tile_origins(Vector2(1920, 1080), Vector2(100, 50))` → `t.size()` ist 9; `t[0]` ist `Vector2(-924, -974)`; `t[8]` ist `Vector2(1124, 1074)`
- `test_ohne_versatz`: `WaterBackdrop.tile_origins(Vector2(1024, 1024), Vector2.ZERO).size()` ist 4

Review (16.10.2026): gemergt.
