extends Node2D

const LENGTH := 44.0
const WIDTH := 22.0
const COLOR := Color(0.75, 0.9, 1.0, 0.35)


func _init() -> void:
	visible = false


func show_at(lap: GhostLap, time: float) -> void:
	if lap == null or lap.is_empty():
		visible = false
		return
	visible = true
	position = lap.position_at(time)
	rotation = lap.heading_at(time)


func _draw() -> void:
	draw_rect(Rect2(-LENGTH * 0.5, -WIDTH * 0.5, LENGTH, WIDTH), COLOR)
