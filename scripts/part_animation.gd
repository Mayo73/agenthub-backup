class_name PartAnimation
extends RefCounted
## Bewegte Teile: Die Geißel schlängelt. Punkte in Zellradien, Ansatz bei (0, 0), Geißel nach -x.

const FLAGELLUM_POINTS := 8
const FLAGELLUM_LENGTH := 0.9
const FLAGELLUM_AMPLITUDE := 0.12
const FLAGELLUM_SPEED := 10.0


## Linienzug der Geißel zur Zeit time. Der Ansatz bewegt sich nicht, das Ende schwingt am stärksten.
static func flagellum(time: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in FLAGELLUM_POINTS:
		var t := float(i) / (FLAGELLUM_POINTS - 1)
		out.append(Vector2(-FLAGELLUM_LENGTH * t, FLAGELLUM_AMPLITUDE * t * sin(time * FLAGELLUM_SPEED - t * 6.0)))
	return out


## Setzt Punkte (in Zellradien, nach -x zeigend) an ein eingebautes Antriebsteil, Ergebnis in Pixeln
## relativ zur Zellmitte. Wie in PartShapes.placed hängen Antriebe von der Zelle nach außen.
static func place_points(points: PackedVector2Array, part: Dictionary, radius: float) -> PackedVector2Array:
	var pos: Vector2 = part["pos"]
	var angle: float = part["angle"]
	if pos != Vector2.ZERO:
		angle = pos.angle() + PI
	var out := PackedVector2Array()
	for p in points:
		out.append(pos * radius + (p * radius).rotated(angle))
	return out
