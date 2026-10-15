class_name TrackPath
extends RefCounted
## Geometrie einer geschlossenen Strecke in Weltkoordinaten: Mittellinie plus Breite.
## Beantwortet: Wo ist die nächste Stelle der Mittellinie? Bin ich auf der Strecke?
## Wie weit bin ich entlang der Strecke gekommen (für Runden)?

## Mittellinie, geschlossen: Der letzte Punkt verbindet zum ersten.
var points := PackedVector2Array()
var width := 280.0
## Gesamtlänge der Mittellinie.
var length := 0.0
var _segment_start := PackedFloat32Array()  # Streckenlänge bis zum Anfang von Segment i


func _init(centerline := PackedVector2Array(), track_width := 280.0) -> void:
	points = centerline
	width = track_width
	for i in points.size():
		_segment_start.append(length)
		length += points[i].distance_to(points[(i + 1) % points.size()])


## Glättet geschlossene Kontrollpunkte zu einer runden Linie (Catmull-Rom).
## Das Ergebnis läuft durch alle Kontrollpunkte; steps = Punkte pro Abschnitt.
static func smooth_closed(control: PackedVector2Array, steps: int) -> PackedVector2Array:
	var result := PackedVector2Array()
	var n := control.size()
	for i in n:
		var p0 := control[(i - 1 + n) % n]
		var p1 := control[i]
		var p2 := control[(i + 1) % n]
		var p3 := control[(i + 2) % n]
		for s in steps:
			var t := float(s) / steps
			var t2 := t * t
			var t3 := t2 * t
			result.append(0.5 * (2.0 * p1 + (p2 - p0) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 + (3.0 * p1 - p0 - 3.0 * p2 + p3) * t3))
	return result


## Nächste Stelle auf der Mittellinie.
## Ergebnis: {"position": Vector2, "segment": int, "progress": float, "offset": float}
## progress = Strecke ab Start entlang der Mittellinie, offset = Abstand zur Mittellinie.
func closest(world: Vector2) -> Dictionary:
	var best := {"position": Vector2.ZERO, "segment": 0, "progress": 0.0, "offset": INF}
	for i in points.size():
		var a := points[i]
		var b := points[(i + 1) % points.size()]
		var on_line := Geometry2D.get_closest_point_to_segment(world, a, b)
		var distance := on_line.distance_to(world)
		if distance < best["offset"]:
			best = {"position": on_line, "segment": i, "progress": _segment_start[i] + a.distance_to(on_line), "offset": distance}
	return best


func distance_from_center(world: Vector2) -> float:
	return closest(world)["offset"]


func is_on_track(world: Vector2) -> bool:
	return distance_from_center(world) <= width * 0.5


## Strecke ab Start entlang der Mittellinie, von 0 bis length.
func progress_at(world: Vector2) -> float:
	return closest(world)["progress"]


## Punkt auf der Mittellinie nach `progress` Pixeln ab Start. Werte über length oder unter 0 laufen im Kreis weiter.
func point_at(progress: float) -> Vector2:
	if points.is_empty() or length <= 0.0:
		return Vector2.ZERO
	var p := fposmod(progress, length)
	var n := points.size()
	for i in n:
		var a := points[i]
		var b := points[(i + 1) % n]
		var seg_len := a.distance_to(b)
		if p <= _segment_start[i] + seg_len:
			if seg_len <= 0.0:
				return a
			return a.lerp(b, (p - _segment_start[i]) / seg_len)
	return points[0]


## Fahrtrichtung der Strecke an der nächsten Stelle (Länge 1).
func direction_at(world: Vector2) -> Vector2:
	var segment: int = closest(world)["segment"]
	return (points[(segment + 1) % points.size()] - points[segment]).normalized()


func start_position() -> Vector2:
	return points[0]


func start_heading() -> float:
	return (points[1] - points[0]).angle()


## Umriss im Abstand delta zur Mittellinie: positiv = Außenkante, negativ = Innenkante.
func outline(delta: float) -> PackedVector2Array:
	var base := points.duplicate()
	if Geometry2D.is_polygon_clockwise(base):
		base.reverse()
	var result := PackedVector2Array()
	var best_area := -1.0
	for polygon in Geometry2D.offset_polygon(base, delta, Geometry2D.JOIN_ROUND):
		var area := absf(_area(polygon))
		if area > best_area:
			best_area = area
			result = polygon
	return result


static func _area(polygon: PackedVector2Array) -> float:
	var sum := 0.0
	for i in polygon.size():
		var a := polygon[i]
		var b := polygon[(i + 1) % polygon.size()]
		sum += a.x * b.y - b.x * a.y
	return sum * 0.5
