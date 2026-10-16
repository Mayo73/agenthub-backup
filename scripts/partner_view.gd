class_name PartnerView
extends Node2D
## Zeichnet den gerufenen Partner (Platzhalter: Zelle mit pulsierendem Ring).

const COLOR := Color(0.5, 0.88, 0.82)
const RING_COLOR := Color(1.0, 0.6, 0.8)

var partner_pos: Variant = null
var time := 0.0


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func _draw() -> void:
	if partner_pos == null:
		return
	var pos := partner_pos as Vector2
	draw_circle(pos, MateCall.PARTNER_RADIUS, COLOR)
	draw_arc(pos, MateCall.PARTNER_RADIUS * (1.6 + 0.3 * sin(time * 3.0)), 0.0, TAU, 32, RING_COLOR, 2.0)
