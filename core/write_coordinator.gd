class_name WriteCoordinator
extends RefCounted

var model: SceneModel
var revision: int = 0
var entries: Array[Dictionary] = []

func _init(scene: SceneModel) -> void:
	model = scene


func set_property(id: String, key: String, value: Variant, base_revision: int, author: String) -> CommandResult:
	if not model.has_object(id):
		return CommandResult.error(CommandResult.NOT_FOUND, "Objekt %s gibt es nicht" % id)

	for entry: Dictionary in entries:
		if entry["id"] == id and entry["key"] == key and entry["revision"] > base_revision:
			var current_value: Variant = model.get_property(id, key)
			return CommandResult.error(
				CommandResult.CONFLICT,
				"Konflikt: %s.%s wurde in Revision %d von %s geändert" % [id, key, entry["revision"], entry["author"]],
				{"current": current_value, "revision": entry["revision"]}
			)

	var old_value: Variant = model.get_property(id, key)
	model.set_property(id, key, value)
	revision += 1
	var entry_dict: Dictionary = {"revision": revision, "author": author, "id": id, "key": key, "old": old_value, "new": value}
	entries.append(entry_dict)

	return CommandResult.success({"revision": revision})


func history(id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in entries:
		if entry["id"] == id:
			result.append(entry.duplicate(true))
	return result
