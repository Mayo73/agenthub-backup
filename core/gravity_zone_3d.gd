class_name GravityZone3D
extends RefCounted

## Bereich mit eigener Schwerkraft (Schwerelosigkeit, Auftrieb etc.).
## Bei Überlappung entscheidet die höchste Priorität.

var box: AABB = AABB()
var gravity: Vector3 = Vector3.ZERO
var priority: int = 0


func _init(area: AABB = AABB(), g: Vector3 = Vector3.ZERO, prio: int = 0) -> void:
	box = area
	gravity = g
	priority = prio


func contains(p: Vector3) -> bool:
	return box.has_point(p)


## Gibt die Schwerkraft an Position p zurück, basierend auf allen Zonen.
## Wählt die Zone mit höchster Priorität; bei Gleichstand die erste in der Liste.
## Keine übereinstimmende Zone → default_g.
static func gravity_at(zones: Array, p: Vector3, default_g: Vector3) -> Vector3:
	var best_zone: GravityZone3D = null
	var best_priority: int = -999999

	for zone in zones:
		if zone is GravityZone3D and zone.contains(p):
			if zone.priority > best_priority:
				best_priority = zone.priority
				best_zone = zone

	if best_zone != null:
		return best_zone.gravity
	return default_g
