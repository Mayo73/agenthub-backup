class_name WaterBackdrop
extends Node2D
## Zeichnet die Schwebeteilchen über den ganzen Bildschirm, gekachelt.

const TEXTURE: Texture2D = preload("res://assets/water/wasser_tiefe.png")
## So stark folgt das Wasserbild der Kamera (langsamer als die Teilchen).
const TEXTURE_FACTOR := 0.1

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
	var tex_offset := ParallaxDots.layer_offset(camera.position, TEXTURE_FACTOR)
	for origin in tile_origins(screen, tex_offset):
		draw_texture_rect(TEXTURE, Rect2(top_left + origin / zoom, Vector2.ONE * ParallaxDots.TILE / zoom), false)
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
