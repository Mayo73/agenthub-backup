class_name TrackDecor
extends RefCounted
## Berechnet, wo neben der Strecke Deko steht (Reifenstapel, Bäume). Zeichnet selbst nichts.

enum Kind { TIRES, TREE }


## Punkte im Abstand `spacing` entlang der Strecke, jeweils `offset` links und rechts der Mittellinie.
## Punkte, die in engen Kurven zu nah an die Mittellinie geraten (unter offset * 0.9), fallen weg.
static func side_points(path: TrackPath, spacing: float, offset: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	if path == null or path.length <= 0.0 or spacing <= 0.0:
		return out
	var d := 0.0
	while d < path.length:
		var p := path.point_at(d)
		var dir := (path.point_at(d + 1.0) - p).normalized()
		var normal := dir.orthogonal()
		for side in [1.0, -1.0]:
			var q: Vector2 = p + normal * offset * side
			if path.distance_from_center(q) >= offset * 0.9:
				out.append(q)
		d += spacing
	return out


## Deko einer Strecke: Reifenstapel knapp neben dem Rand, Bäume weiter draußen.
## Jeder Eintrag: {"kind": Kind, "position": Vector2}.
static func build(path: TrackPath) -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	if path == null:
		return items
	for q in side_points(path, 320.0, path.width * 0.5 + 60.0):
		items.append({"kind": Kind.TIRES, "position": q})
	for q in side_points(path, 450.0, path.width * 0.5 + 260.0):
		items.append({"kind": Kind.TREE, "position": q})
	return items


const STAND_LENGTH := 420.0
const STAND_DEPTH := 120.0
const STAND_GAP := 90.0


## Rechteck (4 Ecken) der Tribüne: links neben der Startlinie, mit STAND_GAP Abstand zum Streckenrand.
static func grandstand(path: TrackPath) -> PackedVector2Array:
	if path == null or path.length <= 0.0:
		return PackedVector2Array()
	var start := path.start_position()
	var forward := Vector2.from_angle(path.start_heading())
	var side := forward.rotated(-PI / 2.0)
	var near := path.width * 0.5 + STAND_GAP
	var a := start + side * near - forward * STAND_LENGTH * 0.5
	var b := start + side * near + forward * STAND_LENGTH * 0.5
	var c := b + side * STAND_DEPTH
	var d := a + side * STAND_DEPTH
	return PackedVector2Array([a, b, c, d])
