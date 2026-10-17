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
