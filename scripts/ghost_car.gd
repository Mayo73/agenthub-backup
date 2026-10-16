extends Node2D

const LENGTH := 44.0
const WIDTH := 22.0
const COLOR := Color(0.75, 0.9, 1.0, 0.35)

var texture: Texture2D


func _init() -> void:
	visible = false


func show_at(lap: GhostLap, time: float) -> void:
	if lap == null or lap.is_empty():
		visible = false
		return
	visible = true
	position = lap.position_at(time)
	rotation = lap.heading_at(time)


## Wählt das Bild des Geisterautos aus dem CarCatalog. Unbekannte IDs werden ignoriert.
func set_car(id: String) -> void:
	if not CarCatalog.has_car(id):
		return
	texture = load(CarCatalog.sprite_of(id)) as Texture2D
	queue_redraw()


func _draw() -> void:
	if texture:
		draw_texture_rect(texture, Rect2(-LENGTH * 0.5, -WIDTH * 0.5, LENGTH, WIDTH), false, COLOR)
	else:
		draw_rect(Rect2(-LENGTH * 0.5, -WIDTH * 0.5, LENGTH, WIDTH), COLOR)
