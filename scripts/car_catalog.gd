class_name CarCatalog
extends RefCounted

const DEFAULT_ID := "allround"

const CARS := {
	"allround": {
		"name": "Allrounder",
		"color": Color(0.86, 0.2, 0.18),
		"tuning": {},
	},
	"grip": {
		"name": "Grip-Coupé",
		"color": Color(0.2, 0.45, 0.9),
		"tuning": {"grip": 34.0, "slide_grip": 2.2, "traction_limit": 1700.0, "max_speed": 740.0, "power_oversteer": 0.8},
	},
	"drifter": {
		"name": "Drift-Kombi",
		"color": Color(0.95, 0.75, 0.15),
		"tuning": {"traction_limit": 1150.0, "slide_grip": 1.2, "handbrake_grip": 0.45, "power_oversteer": 1.5, "drift_steer_bonus": 1.6, "max_speed": 775.0},
	},
}


static func ids() -> Array[String]:
	var result: Array[String] = []
	for key in CARS:
		result.append(key)
	return result


static func has_car(id: String) -> bool:
	return CARS.has(id)


static func name_of(id: String) -> String:
	if not CARS.has(id):
		return ""
	return CARS[id]["name"]


static func color_of(id: String) -> Color:
	if not CARS.has(id):
		return Color.WHITE
	return CARS[id]["color"]


static func apply(id: String, physics: CarPhysics) -> void:
	if not CARS.has(id):
		return
	var tuning := CARS[id]["tuning"] as Dictionary
	for key in tuning:
		physics.set(key, tuning[key])
