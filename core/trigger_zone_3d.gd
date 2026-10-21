extends RefCounted
class_name TriggerZone3D

var id: String = ""
var box: AABB = AABB()
var inside: Dictionary = {}
var events: Array[Dictionary] = []


func _init(zone_id: String = "", zone_box: AABB = AABB()) -> void:
	id = zone_id
	box = zone_box


func update(step: int, positions: Dictionary) -> Array[Dictionary]:
	var new_events: Array[Dictionary] = []

	# IDs sortieren
	var object_ids: Array[String] = []
	for oid in positions.keys():
		object_ids.append(oid)
	object_ids.sort()

	# Jedes Objekt prüfen (IDs sortiert)
	for oid in object_ids:
		var position: Vector3 = positions[oid]
		var is_in_box: bool = box.has_point(position)

		var was_inside: bool = inside.get(oid, false)
		if is_in_box and not was_inside:
			# Betreten: war nicht drin, jetzt drin
			var event: Dictionary = {
				"zone": id,
				"object": oid,
				"type": "entered",
				"step": step
			}
			new_events.append(event)
			inside[oid] = true

		elif not is_in_box and was_inside:
			# Verlassen: war drin, jetzt nicht mehr
			var event: Dictionary = {
				"zone": id,
				"object": oid,
				"type": "exited",
				"step": step
			}
			new_events.append(event)
			inside.erase(oid)

	# Objekte die in inside stehen, aber in positions fehlen (verschwunden)
	var vanished_ids: Array[String] = []
	for oid in inside.keys():
		if not inside.get(oid, false):
			continue
		if not positions.has(oid):
			vanished_ids.append(oid)
	vanished_ids.sort()

	for oid in vanished_ids:
		var event: Dictionary = {
			"zone": id,
			"object": oid,
			"type": "exited",
			"step": step
		}
		new_events.append(event)
		inside.erase(oid)

	# Neue Ereignisse an events anhängen
	for event in new_events:
		events.append(event)

	return new_events


func is_inside(object_id: String) -> bool:
	return inside.get(object_id, false)


func clear() -> void:
	inside.clear()
	events.clear()
