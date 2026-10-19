class_name EditorSession
extends RefCounted

signal selection_changed(id: String)

var model: SceneModel
var selected: String = ""


func _init(scene: SceneModel) -> void:
	model = scene


func select(id: String) -> bool:
	if id == "":
		if selected != "":
			selected = ""
			selection_changed.emit("")
		return true
	if not model.has_object(id):
		return false
	if selected != id:
		selected = id
		selection_changed.emit(id)
	return true


func selected_object() -> Dictionary:
	if selected == "":
		return {}
	return model.get_object(selected)


func validate() -> void:
	if selected != "" and not model.has_object(selected):
		selected = ""
		selection_changed.emit("")


func path_of(id: String) -> Array[String]:
	if not model.has_object(id):
		return []
	var path: Array[String] = []
	var current_id: String = id
	while current_id != "":
		path.push_front(current_id)
		var obj: Dictionary = model.get_object(current_id)
		current_id = obj.get("parent", "")
	return path


func search(text: String) -> Array[String]:
	text = text.strip_edges()
	if text == "":
		return []
	var result: Array[String] = []
	for oid in model.order:
		var obj: Dictionary = model.get_object(oid)
		var found: bool = false
		if oid.findn(text) >= 0:
			found = true
		if not found and obj.get("type", "").findn(text) >= 0:
			found = true
		if not found and obj["props"].has("name"):
			var name_val = str(obj["props"]["name"])
			if name_val.findn(text) >= 0:
				found = true
		if found:
			result.append(oid)
	return result
