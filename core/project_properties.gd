class_name ProjectProperties
extends RefCounted
## Dokumentierte Projekteigenschaften mit Typprüfung und Grenzen.

const SCHEMA: Dictionary = {
	"name": {"type": "string", "default": "Neues Projekt", "text": "Name des Spiels"},
	"dimension": {"type": "string", "default": "2d", "choices": ["2d", "3d"], "text": "2D- oder 3D-Spiel"},
	"physics_hz": {"type": "int", "default": 120, "min": 30, "max": 240, "text": "Physikschritte pro Sekunde"},
	"gravity": {"type": "float", "default": 9.81, "min": 0.0, "max": 100.0, "text": "Schwerkraft in Einheiten/s²"},
	"window_width": {"type": "int", "default": 1280, "min": 320, "max": 7680, "text": "Fensterbreite in Pixeln"}
}

var values: Dictionary = {}


func _init() -> void:
	for key in SCHEMA:
		values[key] = SCHEMA[key]["default"]


func set_value(key: String, value: Variant) -> CommandResult:
	if not key in SCHEMA:
		return CommandResult.error(CommandResult.NOT_FOUND, "Eigenschaft %s gibt es nicht" % key)

	var entry: Dictionary = SCHEMA[key]
	var kind: String = entry["type"]

	# Typprüfung
	if kind == "string":
		if typeof(value) != TYPE_STRING:
			return CommandResult.error(CommandResult.INVALID_ARGUMENT, "%s braucht den Typ string" % key)
	elif kind == "int":
		if typeof(value) != TYPE_INT and (typeof(value) != TYPE_FLOAT or floor(value) != value):
			return CommandResult.error(CommandResult.INVALID_ARGUMENT, "%s braucht den Typ int" % key)
	elif kind == "float":
		if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
			return CommandResult.error(CommandResult.INVALID_ARGUMENT, "%s braucht den Typ float" % key)

	# Bereichsprüfung bei int/float
	if kind in ["int", "float"]:
		var numeric_value = value if typeof(value) == TYPE_INT else float(value)
		if numeric_value < entry["min"] or numeric_value > entry["max"]:
			return CommandResult.error(CommandResult.INVALID_ARGUMENT, "%s ist außerhalb des erlaubten Bereichs" % key)

	# Bereichsprüfung bei choices (nur string)
	if kind == "string" and "choices" in entry:
		if value not in entry["choices"]:
			return CommandResult.error(CommandResult.INVALID_ARGUMENT, "%s ist außerhalb des erlaubten Bereichs" % key)

	# Wert speichern mit korrektem Typ
	if kind == "int":
		values[key] = int(value)
	elif kind == "float":
		values[key] = float(value)
	else:
		values[key] = value

	return CommandResult.success({"key": key, "value": values[key]})


func get_value(key: String) -> Variant:
	return values.get(key, null)


func describe() -> Array[String]:
	var lines: Array[String] = []
	var sorted_keys: Array = SCHEMA.keys()
	sorted_keys.sort()

	for key in sorted_keys:
		var entry: Dictionary = SCHEMA[key]
		lines.append("%s: %s (Standard %s)" % [key, entry["text"], str(entry["default"])])

	return lines


func to_dict() -> Dictionary:
	return values.duplicate(true)


static func from_dict(d: Dictionary) -> ProjectProperties:
	var pp := ProjectProperties.new()
	for key in SCHEMA:
		if key in d:
			var result := pp.set_value(key, d[key])
			if not result.is_ok():
				# Ungültige Werte behalten den Standard (bereits im _init gesetzt)
				pass
	return pp
