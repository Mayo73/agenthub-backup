class_name FishWorld
extends RefCounted
## Maße und Farben der 3D-Unterwasserwelt der Fischphase. Einheit Meter, y zeigt nach oben.

## Wasseroberfläche bei y = 0, Meeresboden bei y = -DEPTH.
const DEPTH := 60.0
## Die Welt reicht in x und z von -HALF_SIZE bis HALF_SIZE.
const HALF_SIZE := 150.0
## Startlage des Spielerfischs.
const START := Vector3(0.0, -20.0, 0.0)

const WATER_COLOR := Color(0.04, 0.2, 0.28)
const FLOOR_COLOR := Color(0.55, 0.5, 0.36)
const SURFACE_COLOR := Color(0.5, 0.8, 0.9, 0.35)
const DEEP_COLOR := Color(0.01, 0.06, 0.13)  ## Wasserfarbe am Meeresboden.


## Hält eine Lage im Wasser: mindestens margin unter der Oberfläche und über dem Boden, innerhalb der Ränder.
static func clamp_to_water(p: Vector3, margin: float = 0.5) -> Vector3:
	return Vector3(
		clampf(p.x, -HALF_SIZE, HALF_SIZE),
		clampf(p.y, -DEPTH + margin, -margin),
		clampf(p.z, -HALF_SIZE, HALF_SIZE))


## Tiefe unter der Oberfläche in Metern (positiv nach unten).
static func depth_of(p: Vector3) -> float:
	return -p.y


## Anteil der Tiefe (0 an der Oberfläche, 1 am Boden).
static func depth_ratio(depth: float) -> float:
	return clampf(depth / DEPTH, 0.0, 1.0)


## Wasserfarbe in dieser Tiefe: oben WATER_COLOR, am Boden DEEP_COLOR.
static func water_color_at(depth: float) -> Color:
	return WATER_COLOR.lerp(DEEP_COLOR, depth_ratio(depth))


## Stärke des Umgebungslichts in dieser Tiefe: 0,9 an der Oberfläche, 0,35 am Boden.
static func ambient_energy_at(depth: float) -> float:
	return lerpf(0.9, 0.35, depth_ratio(depth))
