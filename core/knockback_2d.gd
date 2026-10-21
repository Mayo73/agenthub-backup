class_name Knockback2D
extends RefCounted

## Zurückstoßung für 2D-Objekte.
var velocity: Vector2 = Vector2.ZERO
var decay: float = 8.0


func _init(decay_rate: float = 8.0) -> void:
	decay = decay_rate


func hit(source: Vector2, target: Vector2, strength: float) -> void:
	var direction := (target - source).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2(0, -1)
	velocity += direction * strength


func step(dt: float) -> Vector2:
	var offset: Vector2 = velocity * dt
	velocity = velocity.move_toward(Vector2.ZERO, decay * dt)
	return offset


func active() -> bool:
	return velocity.length() > 0.001
