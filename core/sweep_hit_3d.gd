extends RefCounted
class_name SweepHit3D

const EPSILON := 1e-9

## Strecken-AABB-Schnittprüfung nach dem Slab-Verfahren.
## from: Startpunkt der Strecke
## to: Endpunkt der Strecke
## box: zu prüfender AABB
## Zurück: bei Treffer {t, position, normal}, sonst {}
static func segment_aabb(from: Vector3, to: Vector3, box: AABB) -> Dictionary:
	var diff: Vector3 = to - from
	var length: float = diff.length()

	## Wenn Strecke stehengeblieben ist, prüfen wir nur Punkt-Kollision
	if length < EPSILON:
		if box.has_point(from):
			return {"t": 0.0, "position": from, "normal": Vector3.ZERO}
		return {}

	var t_min: float = 0.0
	var t_max: float = INF
	var entering_axis: int = -1
	var entering_direction: float = 0.0

	var box_pos: Vector3 = box.position
	var size: Vector3 = box.size
	var box_min: Vector3 = box_pos
	var box_max: Vector3 = box_pos + size

	## Normierte Richtung für Slab-Verfahren
	var direction: Vector3 = diff / length

	## Wir prüfen jede Achse mit dem Slab-Verfahren
	for i in range(3):
		var d: float = direction[i]
		var min_val: float = box_min[i] - from[i]
		var max_val: float = box_max[i] - from[i]

		if absf(d) < EPSILON:
			## Keine Bewegung in dieser Achse – muss innerhalb liegen
			if from[i] < box_min[i] or from[i] > box_max[i]:
				return {}
			continue

		var t1: float = min_val / d
		var t2: float = max_val / d

		if t1 > t2:
			var tmp: float = t1
			t1 = t2
			t2 = tmp

		if t1 > t_min:
			t_min = t1
			entering_axis = i
			entering_direction = -1.0 if d > 0.0 else 1.0
		if t2 < t_max:
			t_max = t2

	if t_min > t_max or t_max < 0.0:
		return {}

	var hit_t_param: float = maxf(0.0, t_min) / length
	## Wenn Trefferparameter außerhalb [0,1], kein Treffer am Segment
	if hit_t_param > 1.0:
		return {}
	var hit_pos: Vector3 = from + diff * hit_t_param

	## Wenn Startpunkt innerhalb des Boxes liegt, setze t=0 und berechne normale rauslaufend
	if box.has_point(from):
		hit_t_param = 0.0
		hit_pos = from
		var move_dir: Vector3 = to - from
		if move_dir.length_squared() > 0.0:
			## Normale zeigt entgegengesetzt zur Bewegungsrichtung
			var dir_normalized: Vector3 = move_dir.normalized()
			for i in range(3):
				if absf(dir_normalized[i]) > EPSILON:
					entering_axis = i
					entering_direction = -signf(dir_normalized[i])
					break

	var normal: Vector3 = Vector3.ZERO
	if entering_axis >= 0:
		normal[entering_axis] = entering_direction

	return {"t": hit_t_param, "position": hit_pos, "normal": normal}

## Prüft alle Quader und gibt den frühesten Treffer zurück.
## from: Startpunkt der Strecke
## to: Endpunkt der Strecke
## boxes: Array von AABBs zu prüfen
## Zurück: bei Treffer {t, position, normal, index}, sonst {}
static func first_hit(from: Vector3, to: Vector3, boxes: Array[AABB]) -> Dictionary:
	var best_t: float = INF
	var best_index: int = -1
	var best_position: Vector3 = Vector3.ZERO
	var best_normal: Vector3 = Vector3.ZERO

	for i in range(boxes.size()):
		var result: Dictionary = segment_aabb(from, to, boxes[i])
		if not result.is_empty():
			var t: float = result.get("t", INF)
			if t < best_t:
				best_t = t
				best_index = i
				best_position = result["position"]
				best_normal = result["normal"]

	if best_index >= 0:
		return {"t": best_t, "position": best_position, "normal": best_normal, "index": best_index}

	return {}

## Berechnet die Reflexion einer Geschwindigkeit an einer Oberfläche.
## velocity: ankommende Geschwindigkeit
## normal: Flächennormale (zeigt aus der Oberfläche heraus)
## restitution: Restitutionskoeffizient (0 = keine Elastizität, 1 = vollständig elastisch)
## Zurück: reflektierte Geschwindigkeit
static func reflect(velocity: Vector3, normal: Vector3, restitution: float) -> Vector3:
	return velocity.bounce(normal) * restitution
