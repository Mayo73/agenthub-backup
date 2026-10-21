class_name Spread
extends RefCounted
## Klasse für Streukegel bei Schüssen. Statisch, seed-basiert wiederholbar.


## Berechnet eine gestreute Richtung um die Vorwärtsrichtung im Kegel.
static func direction(forward: Vector3, angle_deg: float, seed_value: int) -> Vector3:
	var f: Vector3 = forward.normalized()
	if angle_deg <= 0.0:
		return f

	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value

	var theta: float = deg_to_rad(angle_deg) * sqrt(rng.randf())
	var phi: float = rng.randf() * TAU

	var up: Vector3 = Vector3.UP if absf(f.dot(Vector3.UP)) < 0.99 else Vector3.RIGHT
	var right: Vector3 = f.cross(up).normalized()
	var up2: Vector3 = right.cross(f)

	return (f * cos(theta) + (right * cos(phi) + up2 * sin(phi)) * sin(theta)).normalized()
