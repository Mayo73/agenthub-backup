extends RefCounted
class_name ShapeOverlap3D

## Statische Methoden für 3D-Kollisionsprüfungen mit Eindringtiefe.


## Kugel-Kugel-Überlappung: Radien minus tatsächlicher Abstand, >0 wenn Überlappung.
static func spheres(c1: Vector3, r1: float, c2: Vector3, r2: float) -> float:
	var dist: float = c1.distance_to(c2)
	var overlap: float = r1 + r2 - dist
	return maxf(overlap, 0.0)


## Box-Box-Überlappung: Eindringtiefe je Achse, Rückgabe entlang der Achse mit kleinster Überlappung.
static func boxes(a: AABB, b: AABB) -> Vector3:
	var ox: float = minf(a.end.x, b.end.x) - maxf(a.position.x, b.position.x)
	var oy: float = minf(a.end.y, b.end.y) - maxf(a.position.y, b.position.y)
	var oz: float = minf(a.end.z, b.end.z) - maxf(a.position.z, b.position.z)
	if ox <= 0.0 or oy <= 0.0 or oz <= 0.0:
		return Vector3.ZERO
	var center_a: Vector3 = a.get_center()
	var center_b: Vector3 = b.get_center()
	if ox <= oy and ox <= oz:
		if center_a.x < center_b.x:
			return Vector3(-ox, 0.0, 0.0)
		else:
			return Vector3(ox, 0.0, 0.0)
	elif oy <= oz:
		if center_a.y < center_b.y:
			return Vector3(0.0, -oy, 0.0)
		else:
			return Vector3(0.0, oy, 0.0)
	else:
		if center_a.z < center_b.z:
			return Vector3(0.0, 0.0, -oz)
		else:
			return Vector3(0.0, 0.0, oz)


## Kugel-Box-Überlappung: Eindringtiefe der Kugel in die Box.
static func sphere_box(c: Vector3, r: float, box: AABB) -> float:
	var nearest: Vector3 = c.clamp(box.position, box.end)
	var dist: float = c.distance_to(nearest)
	var overlap: float = r - dist
	return maxf(overlap, 0.0)


## Punkt-in-Box-Test: alle drei Koordinaten zwischen position und end (Ränder zählen).
static func point_in_box(p: Vector3, box: AABB) -> bool:
	return p.x >= box.position.x and p.x <= box.end.x and \
	       p.y >= box.position.y and p.y <= box.end.y and \
	       p.z >= box.position.z and p.z <= box.end.z
