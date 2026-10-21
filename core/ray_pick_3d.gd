## Kugel-Schnitt eines Strahls.
class_name RayPick3D
extends RefCounted

## Nur statische Funktionen für Raypick-Operationen.


## Berechne den Abstand vom Strahlstart zum ersten Kugeltreffer.
## @param origin: Startpunkt des Strahls
## @param dir: Richtung des Strahls (wird normalisiert)
## @param center: Mittelpunkt der Kugel
## @param radius: Radius der Kugel
## @return: Abstand t bei Treffer, sonst -1.0
static func ray_sphere(origin: Vector3, dir: Vector3, center: Vector3, radius: float) -> float:
	var d: Vector3 = dir.normalized()
	var oc: Vector3 = origin - center
	var b: float = oc.dot(d)
	var c: float = oc.dot(oc) - radius * radius
	var disc: float = b * b - c

	if disc < 0.0:
		return -1.0

	var sqrt_disc: float = sqrt(disc)
	var t: float = -b - sqrt_disc

	if t < 0.0:
		t = -b + sqrt_disc

	if t < 0.0:
		return -1.0

	return t


## Berechne den Abstand vom Strahlstart zum ersten Treffer mit einer achsenparallelen Box.
## @param origin: Startpunkt des Strahls
## @param dir: Richtung des Strahls (wird normalisiert)
## @param box: Achsenparallele Box (AABB)
## @return: Abstand t bei Treffer, sonst -1.0
static func ray_aabb(origin: Vector3, dir: Vector3, box: AABB) -> float:
	var d: Vector3 = dir.normalized()
	var min_vec: Vector3 = box.position
	var max_vec: Vector3 = box.end

	var tmin: float = -1e308
	var tmax: float = 1e308

	for i in 3:
		if abs(d[i]) < 1e-6:
			if origin[i] < min_vec[i] or origin[i] > max_vec[i]:
				return -1.0
		else:
			var t1: float = (min_vec[i] - origin[i]) / d[i]
			var t2: float = (max_vec[i] - origin[i]) / d[i]
			if t1 > t2:
				var tmp: float = t1
				t1 = t2
				t2 = tmp
			tmin = max(tmin, t1)
			tmax = min(tmax, t2)

	if tmax < max(tmin, 0.0):
		return -1.0

	return max(tmin, 0.0)


## Finde das nächstgelegene getroffene Objekt aus einer Liste von Zielen.
## @param origin: Startpunkt des Strahls
## @param dir: Richtung des Strahls
## @param targets: Array mit Ziel-Dictionaries (Kugel oder Box)
## @return: Dictionary mit "id" und "distance" bei Treffer, sonst leeres Dictionary
static func pick(origin: Vector3, dir: Vector3, targets: Array[Dictionary]) -> Dictionary:
	var best_hit_id: String = ""
	var best_hit_distance: float = 1e308

	for target in targets:
		var t_id: String = target["id"]

		if "center" in target and "radius" in target:
			var center: Vector3 = target["center"]
			var radius: float = target["radius"]
			var t: float = ray_sphere(origin, dir, center, radius)
			if t >= 0.0 and (best_hit_id.is_empty() or t < best_hit_distance):
				best_hit_distance = t
				best_hit_id = t_id

		elif "box" in target:
			var box: AABB = target["box"]
			var t: float = ray_aabb(origin, dir, box)
			if t >= 0.0 and (best_hit_id.is_empty() or t < best_hit_distance):
				best_hit_distance = t
				best_hit_id = t_id

	if not best_hit_id.is_empty():
		return {"id": best_hit_id, "distance": best_hit_distance}

	return {}
