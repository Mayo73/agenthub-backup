extends RefCounted
class_name Body3D

## Ein einfacher dynamischer 3D-Körper
## 1 Einheit = 1 Meter, Schwerkraft nach −y

var position: Vector3 = Vector3.ZERO
var velocity: Vector3 = Vector3.ZERO
var mass: float = 1.0
var friction: float = 0.5
var bounce: float = 0.0
var on_floor: bool = false

const GRAVITY: float = 9.81


func apply_impulse(impulse: Vector3) -> void:
	if mass <= 0.0:
		return
	velocity += impulse / mass


func step(dt: float, floor_y: float, gravity: float = GRAVITY) -> void:
	## 1. Schwerkraft und Position aktualisieren
	velocity.y -= gravity * dt
	position += velocity * dt

	## 2. Bodenkollision prüfen (Boden ist y = floor_y, „über dem Boden" heißt y > floor_y)
	if position.y <= floor_y:
		position.y = floor_y
		if velocity.y < 0.0:
			velocity.y = -velocity.y * bounce
			if absf(velocity.y) < 0.05:
				velocity.y = 0.0
		on_floor = true
	else:
		on_floor = false

	## 3. Reibung auf dem Boden anwenden (waagerecht: x und z)
	if on_floor:
		velocity.x = move_toward(velocity.x, 0.0, friction * gravity * dt)
		velocity.z = move_toward(velocity.z, 0.0, friction * gravity * dt)


func run(seconds: float, floor_y: float, hz: int = 120) -> void:
	var steps: int = roundi(seconds * hz)
	for i in range(steps):
		step(1.0 / hz, floor_y)
