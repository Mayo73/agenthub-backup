extends RefCounted
class_name LeadSolver

## Berechnet den Treffpunkt für ein bewegtes Ziel (ohne Schwerkraft, geradeaus Flug).

static func intercept_time(shooter: Vector3, target: Vector3, target_velocity: Vector3, speed: float) -> float:
	if speed <= 0.0:
		return -1.0

	var r: Vector3 = target - shooter
	var a: float = target_velocity.dot(target_velocity) - speed * speed
	var b: float = 2.0 * r.dot(target_velocity)
	var c: float = r.dot(r)

	if absf(a) < 0.000001:
		if absf(b) < 0.000001:
			return -1.0
		return -c / b

	var discriminant: float = b * b - 4.0 * a * c
	if discriminant < 0.0:
		return -1.0

	var sqrt_d: float = sqrt(discriminant)
	var t1: float = (-b + sqrt_d) / (2.0 * a)
	var t2: float = (-b - sqrt_d) / (2.0 * a)

	if t1 > 0.0 and t2 > 0.0:
		return min(t1, t2)
	elif t1 > 0.0:
		return t1
	elif t2 > 0.0:
		return t2

	return -1.0

static func intercept_point(shooter: Vector3, target: Vector3, target_velocity: Vector3, speed: float) -> Vector3:
	var t: float = intercept_time(shooter, target, target_velocity, speed)
	if t < 0.0:
		return target
	return target + target_velocity * t

static func aim_direction(shooter: Vector3, target: Vector3, target_velocity: Vector3, speed: float) -> Vector3:
	var intercept: Vector3 = intercept_point(shooter, target, target_velocity, speed)
	var direction: Vector3 = intercept - shooter
	if direction.length_squared() < 0.000001:
		return Vector3.ZERO
	return direction.normalized()
