extends RefCounted
class_name Body2D

## Ein einfacher dynamischer 2D-Körper
## 1 Einheit = 1 Meter, Schwerkalt nach +y


var position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var mass: float = 1.0
var friction: float = 0.5
var bounce: float = 0.0
var on_floor: bool = false

const GRAVITY: float = 9.81


func apply_impulse(impulse: Vector2) -> void:
	if mass <= 0.0:
		return
	velocity += impulse / mass


func step(dt: float, floor_y: float, gravity: float = GRAVITY) -> void:
	## 1. Schwerkraft und Position aktualisieren
	velocity.y += gravity * dt
	position += velocity * dt

	## 2. Bodenkollision prüfen
	if position.y >= floor_y:
		position.y = floor_y
		if velocity.y > 0.0:
			velocity.y = -velocity.y * bounce
			if absf(velocity.y) < 0.05:
				velocity.y = 0.0
		on_floor = true
	else:
		on_floor = false

	## 3. Reibung auf dem Boden anwenden
	if on_floor:
		var friction_force: float = friction * gravity * dt
		velocity.x = move_toward(velocity.x, 0.0, friction_force)


func run(seconds: float, floor_y: float, hz: int = 120) -> void:
	var steps: int = roundi(seconds * hz)
	for i in range(steps):
		step(1.0 / hz, floor_y)
