extends RefCounted
class_name MaterialPresets

## Statische Klasse für Materialvorlagen und -prüfung
## Ein Material ist: {"albedo": [r, g, b], "roughness": float, "metallic": float, "emission": float}


## Vorlagen-Definitionen
static var _presets: Dictionary = {
	"holz": {"albedo": [0.55, 0.36, 0.2], "roughness": 0.8, "metallic": 0.0, "emission": 0.0},
	"metall": {"albedo": [0.7, 0.7, 0.72], "roughness": 0.3, "metallic": 1.0, "emission": 0.0},
	"stein": {"albedo": [0.5, 0.5, 0.5], "roughness": 0.95, "metallic": 0.0, "emission": 0.0},
	"leuchte": {"albedo": [1.0, 0.9, 0.6], "roughness": 0.5, "metallic": 0.0, "emission": 2.0}
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
	return _deep_copy(_presets[name])


## Material-Parameter prüfen und Liste von Fehlermeldungen zurückgeben
static func validate(material: Dictionary) -> Array[String]:
	var errors: Array[String] = []

	# albedo prüfen - muss existieren und ein Array mit 3 Elementen sein
	if not material.has("albedo"):
		errors.append("albedo braucht drei Werte zwischen 0 und 1")
	elif typeof(material["albedo"]) != TYPE_ARRAY and typeof(material["albedo"]) != TYPE_PACKED_FLOAT32_ARRAY:
		errors.append("albedo braucht drei Werte zwischen 0 und 1")
	else:
		var albedo = material["albedo"]
		if albedo.size() != 3:
			errors.append("albedo braucht drei Werte zwischen 0 und 1")
		else:
			for i in range(3):
				var val: float = float(albedo[i])
				if not (val >= 0.0 and val <= 1.0):
					errors.append("albedo braucht drei Werte zwischen 0 und 1")
					break

	# roughness prüfen (außerhalb 0–1)
	var roughness: float = 0.0 if not material.has("roughness") else float(material["roughness"])
	if not (roughness >= 0.0 and roughness <= 1.0):
		errors.append("roughness muss zwischen 0 und 1 liegen")

	# metallic prüfen (außerhalb 0–1)
	var metallic: float = 0.0 if not material.has("metallic") else float(material["metallic"])
	if not (metallic >= 0.0 and metallic <= 1.0):
		errors.append("metallic muss zwischen 0 und 1 liegen")

	# emission prüfen (außerhalb 0–16)
	var emission: float = 0.0 if not material.has("emission") else float(material["emission"])
	if not (emission >= 0.0 and emission <= 16.0):
		errors.append("emission muss zwischen 0 und 16 liegen")

	return errors


## Zwei Materialien linear mischen (t auf 0–1 begrenzt)
static func blend(a: Dictionary, b: Dictionary, t: float) -> Dictionary:
	t = clampf(t, 0.0, 1.0)

	var albedo_a: Array = [0.0, 0.0, 0.0] if not a.has("albedo") else a["albedo"]
	var albedo_b: Array = [0.0, 0.0, 0.0] if not b.has("albedo") else b["albedo"]

	var result: Dictionary = {}

	# albedo mischen
	var final_albedo := PackedFloat32Array()
	for i in range(3):
		var val_a: float = float(albedo_a[i]) if i < albedo_a.size() else 0.0
		var val_b: float = float(albedo_b[i]) if i < albedo_b.size() else 0.0
		final_albedo.append(lerp(val_a, val_b, t))
	result["albedo"] = final_albedo

	# roughness mischen
	var rough_a: float = float(a.get("roughness", 0.0))
	var rough_b: float = float(b.get("roughness", 0.0))
	result["roughness"] = lerp(rough_a, rough_b, t)

	# metallic mischen
	var metal_a: float = float(a.get("metallic", 0.0))
	var metal_b: float = float(b.get("metallic", 0.0))
	result["metallic"] = lerp(metal_a, metal_b, t)

	# emission mischen
	var emit_a: float = float(a.get("emission", 0.0))
	var emit_b: float = float(b.get("emission", 0.0))
	result["emission"] = lerp(emit_a, emit_b, t)

	return result


## Albedo als Color zurückgeben
static func to_color(material: Dictionary) -> Color:
	var albedo: Array = [0.0, 0.0, 0.0] if not material.has("albedo") else material["albedo"]
	var r: float = float(albedo[0]) if albedo.size() > 0 else 0.0
	var g: float = float(albedo[1]) if albedo.size() > 1 else 0.0
	var b_val: float = float(albedo[2]) if albedo.size() > 2 else 0.0
	return Color(r, g, b_val)


## Tiefe Kopie eines Dictionaries erstellen
static func _deep_copy(obj: Variant) -> Variant:
	if typeof(obj) == TYPE_DICTIONARY:
		var result: Dictionary = {}
		for key in obj.keys():
			result[key] = _deep_copy(obj[key])
		return result
	elif typeof(obj) == TYPE_ARRAY or typeof(obj) == TYPE_PACKED_FLOAT32_ARRAY:
		var arr: PackedFloat32Array = PackedFloat32Array()
		for item in obj:
			arr.append(float(item))
		return arr
	else:
		return obj
