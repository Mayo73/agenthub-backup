class_name PartGeometry
extends RefCounted
## Umrechnung von Teil-Lagen (in Zellradien, Blick nach +x) in Weltkoordinaten.


static func world_point(center: Vector2, heading: float, radius: float, local: Vector2) -> Vector2:
	return center + (local * radius).rotated(heading)
