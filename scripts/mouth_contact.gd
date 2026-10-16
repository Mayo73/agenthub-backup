class_name MouthContact
extends RefCounted
## Berührungen mit dem Maul: Nur was vorn am Maul liegt, zählt.


## Lage des Mauls: vorn auf dem Zellrand in Blickrichtung.
static func mouth_point(center: Vector2, heading: float, radius: float) -> Vector2:
	return center + Vector2.from_angle(heading) * radius


## Berührt das Maul mit Reichweite reach den Kreis um target mit target_radius?
static func touches(mouth: Vector2, reach: float, target: Vector2, target_radius: float) -> bool:
	return mouth.distance_to(target) <= reach + target_radius
