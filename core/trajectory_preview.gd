extends RefCounted
class_name TrajectoryPreview

## Berechnet eine 2D-Flugbahn bis zum ersten Treffer oder Dauer-Limit.
## @param start Startposition
## @param velocity Anfangsgeschwindigkeit
## @param walls Array von Wand-Rechtecken
## @param duration Gesamtdauer der Simulation
## @param hz Schritte pro Sekunde (Standard: 30)
## @param gravity Schwerkraft (Standard: 9.81)
## @return Dictionary mit "points" (PackedVector2Array) und "hit" (Dictionary)
static func preview_2d(start: Vector2, velocity: Vector2, walls: Array[Rect2], duration: float, hz: int = 30, gravity: float = 9.81) -> Dictionary:
	var points: PackedVector2Array = PackedVector2Array()

	var step_times: int = roundi(duration * hz)
	var dt: float = 1.0 / hz

	for i in range(step_times + 1):
		var t: float = float(i) / float(hz)
		var p: Vector2 = Ballistics.position_2d(start, velocity, t, gravity)

		if points.size() > 0:
			var p_vorher: Vector2 = points[points.size() - 1]
			var hit := SweepHit.first_hit(p_vorher, p, walls)
			if not hit.is_empty():
				points.append(hit["position"])
				return { "points": points, "hit": hit }

		points.append(p)

	return { "points": points, "hit": {} }

## Konvertiert einen PackedVector2Array zu einem Array für JSON-Ausgabe.
## @param points Punktwolke mit Vektor2-Positionsvektoren
## @return Array von [[x, y], …] Arrays
static func to_array(points: PackedVector2Array) -> Array:
	var result: Array = []
	for p: Vector2 in points:
		result.append([p.x, p.y])
	return result
