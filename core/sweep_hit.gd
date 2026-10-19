class_name SweepHit

extends RefCounted
## Klasse zum Prüfen von Treffern zwischen Strecke und Rechtecken (Slab-Verfahren).

## Strecken-Rechteck-Schnitt.
## @param from Startpunkt der Strecke
## @param to Endpunkt der Strecke
## @param rect achsenparalleles Rechteck
## @return Dictionary mit t, position, normal bei Treffer; sonst leeres Dictionary
static func segment_rect(from: Vector2, to: Vector2, rect: Rect2) -> Dictionary:
	var dir := to - from
	var t_min: float = 0.0
	var t_max: float = 1.0

	for axis in 2:
		if abs(dir[axis]) < 1e-9:
			if from[axis] < rect.position[axis] or from[axis] > rect.end[axis]:
				return {}
		else:
			var inv_dir := 1.0 / dir[axis]
			var t1 := (rect.position[axis] - from[axis]) * inv_dir
			var t2 := (rect.end[axis] - from[axis]) * inv_dir

			if t1 > t2:
				var tmp := t1
				t1 = t2
				t2 = tmp

			if t1 > t_min:
				t_min = t1
			if t2 < t_max:
				t_max = t2

		if t_min > t_max:
			return {}

	if t_max < 0.0 or t_min > 1.0:
		return {}

	t_min = max(0.0, t_min)
	t_max = min(1.0, t_max)

	var from_inside := rect.has_point(from)
	var hit_t := t_min

	if not from_inside:
		var position := from + dir * hit_t
		var normal := Vector2.ZERO
		var epsilon := 1e-6

		# Prüfen wo wir getroffen haben (linke/rechte/obere/untere Seite)
		var dist_left := rect.position.x - position.x
		var dist_right := position.x - rect.end.x
		var dist_bottom := rect.position.y - position.y
		var dist_top := position.y - rect.end.y

		if abs(dir.x) < epsilon:
			# Vertikale Strecke -> x konstant → trifft an oberen/unteren Seiten (y-Normalen)
			if dir.y > 0.0 or dist_bottom >= 0:
				normal = Vector2(0.0, -1.0)
			else:
				normal = Vector2(0.0, 1.0)
		elif abs(dir.y) < epsilon:
			# Horizontale Strecke -> y konstant → trifft an linken/rechten Seiten (x-Normalen)
			if dir.x > 0.0 or dist_left >= 0:
				normal = Vector2(-1.0, 0.0)
			else:
				normal = Vector2(1.0, 0.0)
		else:
			# Bestimmen welche Seite zuerst getroffen wird (eintritt in Rechteck)
			var t_left := (rect.position.x - from.x) / dir.x if abs(dir.x) > epsilon else 1e9
			var t_right := (rect.end.x - from.x) / dir.x if abs(dir.x) > epsilon else 1e9
			var t_bottom := (rect.position.y - from.y) / dir.y if abs(dir.y) > epsilon else 1e9
			var t_top := (rect.end.y - from.y) / dir.y if abs(dir.y) > epsilon else 1e9

			if abs(hit_t - t_left) < epsilon:
				normal = Vector2(-1.0, 0.0)
			elif abs(hit_t - t_right) < epsilon:
				normal = Vector2(1.0, 0.0)
			elif abs(hit_t - t_bottom) < epsilon:
				normal = Vector2(0.0, -1.0)
			elif abs(hit_t - t_top) < epsilon:
				normal = Vector2(0.0, 1.0)

		return { "t": hit_t, "position": position, "normal": normal }
	else:
		# Startet im Rechteck -> Normale zeigt zurück
		var back_dir := -(to - from).normalized()
		return { "t": 0.0, "position": from, "normal": back_dir }

## Erster Treffer mit Position und Index der Wand.
## @param from Startpunkt der Strecke
## @param to Endpunkt der Strecke
## @param walls Array von Wänden (Rechtecken)
## @return Dictionary mit t, position, normal, index bei erstem Treffer; sonst leeres Dictionary
static func first_hit(from: Vector2, to: Vector2, walls: Array[Rect2]) -> Dictionary:
	var best: Dictionary = {}
	for i in walls.size():
		var hit: Dictionary = segment_rect(from, to, walls[i])
		if hit.is_empty():
			continue
		var t: float = hit["t"]
		if best.is_empty() or t < float(best["t"]):
			hit["index"] = i
			best = hit
	return best

## Vektor an Wand reflektieren (Rückprall).
## @param velocity Geschwindigkeitsvektor vor dem Aufprall
## @param normal Normale der getroffenen Fläche (zeigt aus der Wand heraus)
## @param restitution Rückstoßkoeffizient (0 = kein Bounce, 1 = perfekt elastisch)
## @return reflektierter Vektor
static func reflect(velocity: Vector2, normal: Vector2, restitution: float) -> Vector2:
	return velocity.bounce(normal) * restitution
