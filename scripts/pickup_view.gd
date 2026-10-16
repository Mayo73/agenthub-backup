class_name PickupView
extends Node2D
## Zeichnet die Teilefunde (Platzhalter: pulsierende helle Rauten).

const COLOR := Color(1.0, 0.95, 0.6)
const TEXTURE: Texture2D = preload("res://assets/pickups/teilefund.png")
## Das Bild ist etwas größer als der Berührungsradius, weil es einen leuchtenden Rand hat.
const SPRITE_SCALE := 1.3

var pickups: PartPickups
var time := 0.0


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


## Eckpunkte der Raute um pos. Die Größe pulsiert mit der Zeit t zwischen dem 0,8- und 1,2-fachen von PartPickups.RADIUS.
static func diamond(pos: Vector2, t: float) -> PackedVector2Array:
	var s := PartPickups.RADIUS * (1.0 + 0.2 * sin(t * 4.0))
	return PackedVector2Array([pos + Vector2(s, 0), pos + Vector2(0, s), pos + Vector2(-s, 0), pos + Vector2(0, -s)])


## Rechteck für das Bild eines Fundes bei pos; pulsiert mit der Zeit t wie diamond().
static func sprite_rect(pos: Vector2, t: float) -> Rect2:
	var s := PartPickups.RADIUS * (1.0 + 0.2 * sin(t * 4.0)) * SPRITE_SCALE
	return Rect2(pos - Vector2(s, s), Vector2(s, s) * 2.0)


func _draw() -> void:
	if pickups == null:
		return
	for p in pickups.positions:
		draw_texture_rect(TEXTURE, sprite_rect(p, time), false)
