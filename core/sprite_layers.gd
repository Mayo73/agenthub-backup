class_name SpriteLayers
extends RefCounted
## Benannte Ebenen mit fester Reihenfolge für 2D-Szenen.
## Hinten (Hintergrund) bis vorne (Oberfläche), z-Indizes berechnen sich daraus.

const DEFAULT_LAYERS: Array[String] = ["hintergrund", "welt", "figuren", "vordergrund"]
const STEP := 100

var layers: Array[String] = []
var assignment: Dictionary = {}


func _init() -> void:
	layers = DEFAULT_LAYERS.duplicate()


func add_layer(name: String, index: int = -1) -> CommandResult:
	if name == "":
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Ebene darf nicht leer sein")

	if not layers.has(name):
		pass
	else:
		return CommandResult.error(CommandResult.CONFLICT, "Ebene %s gibt es schon" % name)

	var insert_index: int = clampi(index, 0, layers.size()) if index >= 0 else layers.size()
	layers.insert(insert_index, name)
	return CommandResult.success({"layers": layers})


func move_layer(name: String, index: int) -> CommandResult:
	if not layers.has(name):
		return CommandResult.error(CommandResult.NOT_FOUND, "Ebene %s nicht gefunden" % name)

	var current_index := layers.find(name)
	layers.remove_at(current_index)

	var max_index: int = layers.size()
	var clamped_index: int = clamp(index, 0, max_index)
	layers.insert(clamped_index, name)

	return CommandResult.success({"layers": layers})


func remove_layer(name: String) -> CommandResult:
	if not layers.has(name):
		return CommandResult.error(CommandResult.NOT_FOUND, "Ebene %s nicht gefunden" % name)

	if layers.size() == 1:
		return CommandResult.error(CommandResult.DEPENDENCY, "Die letzte Ebene kann nicht entfernt werden")

	var remove_index := layers.find(name)
	var assigned_objects := assignment.keys()
	for obj_id in assigned_objects:
		if assignment[obj_id] == name:
			assignment[obj_id] = layers[0]

	layers.remove_at(remove_index)
	return CommandResult.success({"layers": layers})


func assign(object_id: String, layer: String) -> CommandResult:
	if not layers.has(layer):
		return CommandResult.error(CommandResult.NOT_FOUND, "Ebene %s nicht gefunden" % layer)

	assignment[object_id] = layer
	return CommandResult.success({"object_id": object_id, "layer": layer})


func layer_of(object_id: String) -> String:
	if assignment.has(object_id):
		var layer: String = assignment[object_id]
		if layers.has(layer):
			return layer
	return "welt" if layers.has("welt") else layers[0]


func z_index_of(object_id: String) -> int:
	var layer_name := layer_of(object_id)
	return layers.find(layer_name) * STEP


func to_dict() -> Dictionary:
	return {
		"layers": layers.duplicate(),
		"assignment": assignment.duplicate()
	}


static func from_dict(d: Dictionary) -> SpriteLayers:
	var instance := SpriteLayers.new()
	var saved_layers: Array = d.get("layers", [])
	if not saved_layers.is_empty():
		instance.layers.clear()
		for layer in saved_layers:
			instance.layers.append(str(layer))
	var saved_assignment: Dictionary = d.get("assignment", {})
	instance.assignment = saved_assignment.duplicate()
	return instance
