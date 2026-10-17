class_name ZapView
extends Node2D
## Zeichnet nach einer Entladung kurz aufleuchtende Blitze (ElectricArcs).

const COLOR := Color(0.6, 0.9, 1.0)
const DURATION := 0.2

var lines: Array[PackedVector2Array] = []
var time_left := 0.0
var _seed := 1


## Je ein Blitz von from zu jedem Punkt in targets; ersetzt die bisherigen Blitze.
func show_zaps(from: Vector2, targets: Array[Vector2]) -> void:
	lines.clear()
	for t in targets:
		_seed += 1
		lines.append(ElectricArcs.arc(from, t, 6, 6.0, _seed))
	time_left = DURATION


func tick(delta: float) -> void:
	time_left = maxf(0.0, time_left - delta)
	if time_left <= 0.0:
		lines.clear()


func is_zap_visible() -> bool:
	return time_left > 0.0 and not lines.is_empty()


func _process(delta: float) -> void:
	tick(delta)
	queue_redraw()


func _draw() -> void:
	var c := COLOR
	c.a = clampf(time_left / DURATION, 0.0, 1.0)
	for l in lines:
		draw_polyline(l, c, 2.0)
