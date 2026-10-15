class_name TrackCatalog
extends RefCounted

const DEFAULT_ID := "hafen"

const TRACKS := {
	"hafen": {
		"name": "Hafenring",
		"width": 280.0,
		"points": [
			Vector2(0, 0), Vector2(1400, 0), Vector2(2000, 200), Vector2(2300, 700),
			Vector2(2150, 1300), Vector2(1650, 1550), Vector2(1150, 1350), Vector2(750, 1600),
			Vector2(200, 1650), Vector2(-450, 1400), Vector2(-700, 850), Vector2(-600, 350),
			Vector2(-350, 80),
		],
	},
}


static func ids() -> Array[String]:
	var result: Array[String] = []
	for key in TRACKS:
		result.append(key)
	return result


static func has_track(id: String) -> bool:
	return TRACKS.has(id)


static func name_of(id: String) -> String:
	if not TRACKS.has(id):
		return ""
	return TRACKS[id]["name"]


static func width_of(id: String) -> float:
	if not TRACKS.has(id):
		return 280.0
	return TRACKS[id]["width"]


static func points_of(id: String) -> PackedVector2Array:
	if not TRACKS.has(id):
		return PackedVector2Array()
	var track_data = TRACKS[id] as Dictionary
	var result := PackedVector2Array()
	for point in track_data["points"]:
		result.append(point)
	return result
