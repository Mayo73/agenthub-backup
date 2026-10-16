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
