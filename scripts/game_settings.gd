class_name GameSettings
extends RefCounted

static var track_id: String = TrackCatalog.DEFAULT_ID
static var car_id: String = CarCatalog.DEFAULT_ID


## Nächster (dir = 1) oder vorheriger (dir = -1) Eintrag, im Kreis. Unbekannt → erster Eintrag.
static func step_id(ids: Array[String], current: String, dir: int) -> String:
	if ids.is_empty():
		return current
	var i := ids.find(current)
	if i < 0:
		return ids[0]
	return ids[(i + dir + ids.size()) % ids.size()]


static func next_track() -> void:
	track_id = step_id(TrackCatalog.ids(), track_id, 1)


static func previous_track() -> void:
	track_id = step_id(TrackCatalog.ids(), track_id, -1)


static func next_car() -> void:
	car_id = step_id(CarCatalog.ids(), car_id, 1)


static func previous_car() -> void:
	car_id = step_id(CarCatalog.ids(), car_id, -1)
