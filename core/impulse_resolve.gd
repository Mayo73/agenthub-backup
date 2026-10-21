class_name ImpulseResolve
extends RefCounted

## Statische Funktionen zur Berechnung der Stoßantwort zweier Körper.

static func inv_mass(m: float) -> float:
	if m <= 0.0:
		return 0.0
	return 1.0 / m

static func resolve(v1: Vector2, m1: float, v2: Vector2, m2: float, normal: Vector2, restitution: float) -> Array[Vector2]:
	var n := normal.normalized()
	var rel := (v2 - v1).dot(n)
	if rel >= 0.0:
		return [v1, v2]

	var inv_m1 := inv_mass(m1)
	var inv_m2 := inv_mass(m2)

	if inv_m1 + inv_m2 == 0.0:
		return [v1, v2]

	var j := -(1.0 + restitution) * rel / (inv_m1 + inv_m2)

	var new_v1 := v1 - n * j * inv_m1
	var new_v2 := v2 + n * j * inv_m2

	return [new_v1, new_v2]

static func resolve_3d(v1: Vector3, m1: float, v2: Vector3, m2: float, normal: Vector3, restitution: float) -> Array[Vector3]:
	var n := normal.normalized()
	var rel := (v2 - v1).dot(n)
	if rel >= 0.0:
		return [v1, v2]

	var inv_m1 := inv_mass(m1)
	var inv_m2 := inv_mass(m2)

	if inv_m1 + inv_m2 == 0.0:
		return [v1, v2]

	var j := -(1.0 + restitution) * rel / (inv_m1 + inv_m2)

	var new_v1 := v1 - n * j * inv_m1
	var new_v2 := v2 + n * j * inv_m2

	return [new_v1, new_v2]

static func impulse_for(mass: float, dv: Vector2) -> Vector2:
	return dv * mass
