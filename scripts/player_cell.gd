class_name PlayerCell
extends Node2D
## Die Zelle des Spielers. Bewegung in CellMotion, Darstellung als Platzhalter mit _draw().

const COLOR := Color(0.5, 0.88, 0.82)
const MOUTH_COLOR := Color(0.1, 0.3, 0.3)

var motion := CellMotion.new()
var radius := 12.0
var input_enabled := true
var diet := Diet.PFLANZENFRESSER


func _physics_process(delta: float) -> void:
	if not input_enabled:
		drive(delta, Vector2.ZERO)
		return
	var mouse_held := Input.is_action_pressed("schwimmen")
	drive(delta, PlayerInput.wish(Controls.key_vector(), mouse_held, get_global_mouse_position(), global_position))


## Bewegt die Zelle um einen Zeitschritt und überträgt Lage und Ausrichtung auf den Node.
func drive(delta: float, wish: Vector2) -> void:
	motion.step(delta, wish)
	position = motion.position
	rotation = motion.heading
	queue_redraw()


func mouth_point() -> Vector2:
	return MouthContact.mouth_point(motion.position, motion.heading, radius)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, COLOR)
	draw_circle(Vector2(radius * 0.8, 0), radius * 0.25, MOUTH_COLOR)
