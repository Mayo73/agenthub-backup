extends RefCounted
class_name LightPresets

## Statische Klasse für Lichtvorlagen und -prüfung
## Ein Licht ist: {"kind": "sonne"/"lampe", "color": [r,g,b], "energy": float, "rotation": [x,y,z] Grad, "range": float (nur Lampe), "shadows": bool}


## Vorlagen-Definitionen
static var _presets: Dictionary = {
	"mittag": {"kind": "sonne", "color": [1.0, 1.0, 1.0], "energy": 1.2, "rotation": [-60.0, 30.0, 0.0], "range": 0.0, "shadows": true},
	"abend": {"kind": "sonne", "color": [1.0, 0.6, 0.3], "energy": 0.7, "rotation": [-15.0, 60.0, 0.0], "range": 0.0, "shadows": true},
	"innen": {"kind": "lampe", "color": [1.0, 0.9, 0.8], "energy": 1.0, "rotation": [0.0, 0.0, 0.0], "range": 8.0, "shadows": false}
}


## Alle Vorlagennamen sortiert zurückgeben
static func names() -> Array[String]:
	var result: Array[String] = []
	for key in _presets.keys():
		result.append(key)
	result.sort_custom(func(a: String, b: String): return a < b)
	return result


## Vorlage mit gegebenem Namen zurückgeben (tiefe Kopie oder {})
static func get_preset(name: String) -> Dictionary:
	if not _presets.has(name):
		return {}
	var vorlage: Dictionary = _presets[name]
	return vorlage.duplicate(true)


## Licht-Parameter prüfen und Liste von Fehlermeldungen zurückgeben
static func validate(light: Dictionary) -> Array[String]:
	var errors: Array[String] = []

	var kind = light.get("kind", "")
	if kind != "sonne" and kind != "lampe":
		errors.append("Art %s gibt es nicht" % kind)

	# Energie prüfen (0–16)
	var energy: float = 0.0 if not light.has("energy") else float(light["energy"])
	if energy < 0.0 or energy > 16.0:
		errors.append("Energie muss zwischen 0 und 16 liegen")

	# Rotation prüfen (muss Array mit genau 3 Zahlen sein)
	if not light.has("rotation"):
		errors.append("Rotation muss drei Zahlen sein")
	elif typeof(light["rotation"]) != TYPE_ARRAY and typeof(light["rotation"]) != TYPE_PACKED_FLOAT32_ARRAY:
		errors.append("Rotation muss drei Zahlen sein")
	else:
		var rotation = light["rotation"]
		if rotation.size() != 3:
			errors.append("Rotation muss drei Zahlen sein")

	# Lampe mit Reichweite ≤ 0 prüfen
	if kind == "lampe":
		var range_val: float = 0.0 if not light.has("range") else float(light["range"])
		if range_val <= 0.0:
			errors.append("Lampe mit Reichweite ≤ 0")

	return errors


## Energie am gegebenen Abstand berechnen
static func energy_at(light: Dictionary, distance: float) -> float:
	var kind = light.get("kind", "sonne")
	var energy: float = 1.0 if not light.has("energy") else float(light["energy"])

	if kind == "sonne":
		return energy
	else:
		var range_val: float = 0.0 if not light.has("range") else float(light["range"])
		if range_val > 0.0:
			return energy * clampf(1.0 - distance / range_val, 0.0, 1.0)
		return energy


## Farbe als Color zurückgeben
static func to_color(light: Dictionary) -> Color:
	var albedo: Array = [0.0, 0.0, 0.0] if not light.has("color") else light["color"]
	var r: float = float(albedo[0]) if albedo.size() > 0 else 0.0
	var g: float = float(albedo[1]) if albedo.size() > 1 else 0.0
	var b_val: float = float(albedo[2]) if albedo.size() > 2 else 0.0
	return Color(r, g, b_val)
