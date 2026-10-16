class_name CellMotion
extends RefCounted
## Schwimmbewegung einer Zelle in Weltkoordinaten. heading in Radiant, 0 = nach rechts.

var position := Vector2.ZERO
var velocity := Vector2.ZERO
var heading := 0.0
var acceleration := 600.0
var max_speed := 220.0
## Anteil des Tempos, der ohne Eingabe pro Sekunde verloren geht.
var drag := 2.5
## Wendegeschwindigkeit in Radiant pro Sekunde.
var turn_rate := 6.0


## Ein Zeitschritt. wish = gewünschte Richtung (Länge höchstens 1, sonst wird normalisiert).
func step(delta: float, wish: Vector2) -> void:
	if wish.length() > 1.0:
		wish = wish.normalized()
	if wish != Vector2.ZERO:
		velocity += wish * acceleration * delta
		heading = rotate_toward(heading, wish.angle(), turn_rate * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, velocity.length() * drag * delta)
	velocity = velocity.limit_length(max_speed)
	position += velocity * delta


func speed() -> float:
	return velocity.length()


## Stößt die Zelle in Richtung direction (wird normalisiert) mit strength Pixeln pro Sekunde an.
func knockback(direction: Vector2, strength: float) -> void:
	if direction == Vector2.ZERO:
		return
	velocity += direction.normalized() * strength
