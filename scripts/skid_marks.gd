extends Node2D
const REAR_OFFSET := 22.0
const HALF_TRACK := 11.0
const LINE_WIDTH := 5.0
const LINE_COLOR := Color(0.06, 0.06, 0.07, 0.55)

var left := SkidTrail.new()
var right := SkidTrail.new()


func track_car(car: CarPhysics) -> void:
	var back := car.position - car.forward() * REAR_OFFSET
	var side := car.right() * HALF_TRACK
	var marking := car.is_drifting()
	left.update(back - side, marking)
	right.update(back + side, marking)
	queue_redraw()


func _draw() -> void:
	for trail in left.trails:
		if trail.size() >= 2:
			draw_polyline(trail, LINE_COLOR, LINE_WIDTH)
	for trail in right.trails:
		if trail.size() >= 2:
			draw_polyline(trail, LINE_COLOR, LINE_WIDTH)


## Entfernt alle Spuren (neues Rennen).
func clear() -> void:
	left.clear()
	right.clear()
	queue_redraw()
