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
	"altstadt": {
		"name": "Altstadtkurs",
		"width": 240.0,
		"points": [
			Vector2(0, 0), Vector2(1000, 0), Vector2(1300, 150), Vector2(1350, 450),
			Vector2(1100, 650), Vector2(700, 700), Vector2(550, 900), Vector2(700, 1150),
			Vector2(1200, 1200), Vector2(1500, 1400), Vector2(1450, 1800), Vector2(1000, 1950),
			Vector2(400, 1900), Vector2(-100, 1700), Vector2(-200, 1300), Vector2(-500, 1050),
			Vector2(-650, 650), Vector2(-450, 250), Vector2(-250, 50),
		],
	},
	"kurvenring": {
		"name": "Kurvenring",
		"width": 320.0,
		"points": [
			Vector2(0, 0), Vector2(1200, 0), Vector2(2000, 250), Vector2(2500, 800),
			Vector2(2550, 1500), Vector2(2200, 2050), Vector2(1500, 2300), Vector2(800, 2150),
			Vector2(400, 1700), Vector2(-200, 1550), Vector2(-800, 1700), Vector2(-1350, 1450),
			Vector2(-1500, 850), Vector2(-1200, 300), Vector2(-600, 30),
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
