class_name EditorSymmetry
extends RefCounted
## Spiegelt Teile an der Längsachse der Zelle (Blickrichtung +x), wie die Symmetrie im Spore-Editor.

## Teile, die so nah an der Achse liegen (in Zellradien), werden nicht gespiegelt.
const AXIS_TOLERANCE := 0.05


static func is_on_axis(pos: Vector2) -> bool:
	return absf(pos.y) <= AXIS_TOLERANCE


static func mirror_pos(pos: Vector2) -> Vector2:
	return Vector2(pos.x, -pos.y)


static func mirror_angle(angle: float) -> float:
	return -angle


## Baut ein Teil ein und abseits der Achse zusätzlich sein Spiegelbild.
## Gibt die Indizes der eingebauten Teile zurück; leer, wenn das Teil gesperrt ist.
static func place_mirrored(session: EditorSession, id: String, pos: Vector2, angle: float = 0.0) -> Array[int]:
	var result: Array[int] = []
	var first := session.place(id, pos, angle)
	if first < 0:
		return result
	result.append(first)
	if not is_on_axis(pos):
		result.append(session.place(id, mirror_pos(pos), mirror_angle(angle)))
	return result
