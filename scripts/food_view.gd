class_name FoodView
extends Node2D
## Zeichnet alle Nahrungsstücke eines FoodField (Platzhalter: Kreise).

const PLANT_COLOR := Color(0.42, 0.8, 0.37)
const MEAT_COLOR := Color(0.85, 0.33, 0.31)

var field: FoodField


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if field == null:
		return
	for item in field.items:
		draw_circle(item.position, item.radius, PLANT_COLOR if item.kind == Diet.PFLANZE else MEAT_COLOR)
