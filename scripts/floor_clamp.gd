class_name FloorClamp
extends RefCounted
## Begrenzung des Fisches im Wasser über dem gewellten Meeresboden.
## Keine Ränder in x und z, nur y wird begrenzt.

const SURFACE_MARGIN := 0.5
const FLOOR_MARGIN := 1.0


## Hält eine Lage im Wasser: y wird zwischen Bodenhöhe + FLOOR_MARGIN und -SURFACE_MARGIN begrenzt.
## x und z bleiben unverändert (keine Ränder).
static func clamp_to_water(p: Vector3, floor: SeafloorHeight) -> Vector3:
	return Vector3(
		p.x,
		clampf(p.y, floor.height_at(p.x, p.z) + FLOOR_MARGIN, -SURFACE_MARGIN),
		p.z)


## Höhe über dem Meeresboden in Metern (positiv nach oben).
static func height_above_floor(p: Vector3, floor: SeafloorHeight) -> float:
	return p.y - floor.height_at(p.x, p.z)


## Prüft, ob sich die Lage im Wasser befindet.
## Wahr wenn y < 0.0 und y > Bodenhöhe an dieser Stelle.
static func is_in_water(p: Vector3, floor: SeafloorHeight) -> bool:
	return p.y < 0.0 and p.y > floor.height_at(p.x, p.z)
