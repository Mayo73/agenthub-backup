extends RefCounted
class_name Spring2D

## Eine Feder, die zwei 2D-Körper verbindet und auf ihre Ruhelänge zieht.
## Mit Dämpfung für realistischere Bewegung.

var a: Body2D
var b: Body2D
var anchor: Vector2 = Vector2.ZERO
var rest_length: float = 1.0
var stiffness: float = 50.0
var damping: float = 2.0


func _init(body_a: Body2D, body_b: Body2D = null, length: float = 1.0) -> void:
	a = body_a
	b = body_b
	rest_length = length


func other_point() -> Vector2:
	if b != null:
		return b.position
	else:
		return anchor


func force_on_a() -> Vector2:
	var d: Vector2 = other_point() - a.position

	if d.length_squared() < 0.0001:
		return Vector2.ZERO

	var direction: Vector2 = d.normalized()
	var stretch: float = d.length() - rest_length

	var spring_force: Vector2 = stiffness * stretch * direction

	var b_vel: Vector2 = Vector2.ZERO
	if b != null:
		b_vel = b.velocity

	var rel_vel: Vector2 = a.velocity - b_vel
	var vel_along_direction: float = rel_vel.dot(direction)
	var damp_force: Vector2 = damping * vel_along_direction * direction

	return spring_force - damp_force


func apply(dt: float) -> void:
	var force: Vector2 = force_on_a()
	a.apply_impulse(force * dt)

	if b != null:
		b.apply_impulse(-force * dt)


func length() -> float:
	var d: Vector2 = other_point() - a.position
	return d.length()
