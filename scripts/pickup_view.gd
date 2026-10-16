class_name PickupView
extends Node2D
## Zeichnet die Teilefunde (Platzhalter: pulsierende helle Rauten).

const COLOR := Color(1.0, 0.95, 0.6)

var pickups: PartPickups
var time := 0.0


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


## Eckpunkte der Raute um pos. Die Größe pulsiert mit der Zeit t zwischen dem 0,8- und 1,2-fachen von PartPickups.RADIUS.
static func diamond(pos: Vector2, t: float) -> PackedVector2Array:
	var s := PartPickups.RADIUS * (1.0 + 0.2 * sin(t * 4.0))
	return PackedVector2Array([pos + Vector2(s, 0), pos + Vector2(0, s), pos + Vector2(-s, 0), pos + Vector2(0, -s)])


func _draw() -> void:
	if pickups == null:
		return
	for p in pickups.positions:
		draw_colored_polygon(diamond(p, time), COLOR)
