class_name SceneModel
extends RefCounted

var objects: Dictionary = {}
var order: Array[String] = []
var next_id: int

func _init():
	next_id = 1

func add_object(type: String, parent_id: String = "", props: Dictionary = {}) -> String:
	if not parent_id.is_empty() and not objects.has(parent_id):
		return ""
	var id: String = "o%d" % next_id
	next_id += 1
	objects[id] = {"id": id, "type": type, "parent": parent_id, "props": props.duplicate(true)}
	order.append(id)
	return id

func has_object(id: String) -> bool:
	return objects.has(id)

func get_object(id: String) -> Dictionary:
	if not objects.has(id):
		return {}
	var obj: Dictionary = objects[id]
	return {"id": obj["id"], "type": obj["type"], "parent": obj["parent"], "props": obj["props"].duplicate(true)}

func children(parent_id: String) -> Array[String]:
	var result: Array[String] = []
	for oid in order:
		if objects[oid]["parent"] == parent_id:
			result.append(oid)
	return result

func remove_object(id: String) -> bool:
	if not objects.has(id):
		return false
	var to_remove := _get_all_descendants(id)
	for oid in to_remove:
		objects.erase(oid)
		order.erase(oid)
	return true

func _get_all_descendants(id: String) -> Array[String]:
	var result: Array[String] = [id]
	var child_ids: Array[String] = children(id)
	for cid in child_ids:
		result.append_array(_get_all_descendants(cid))
	return result

func set_property(id: String, key: String, value: Variant) -> bool:
	if not objects.has(id):
		return false
	objects[id]["props"][key] = value
	return true

func get_property(id: String, key: String, default: Variant = null) -> Variant:
	if not objects.has(id):
		return default
	if not objects[id]["props"].has(key):
		return default
	return objects[id]["props"][key]

func duplicate_object(id: String) -> String:
	if not objects.has(id):
		return ""
	var old_obj: Dictionary = objects[id]
	var new_id: String = add_object(old_obj["type"], old_obj["parent"], old_obj["props"].duplicate(true))
	return new_id

func to_dict() -> Dictionary:
	var objs_array := []
	for oid in order:
		var obj: Dictionary = objects[oid]
		objs_array.append({"id": obj["id"], "type": obj["type"], "parent": obj["parent"], "props": obj["props"]})
	return {"next_id": int(next_id), "objects": objs_array}

func load_from(d: Dictionary) -> void:
	next_id = int(d.get("next_id", 1))
	objects.clear()
	order.clear()
	var objects_list: Array = d.get("objects", [])
	for obj_dict: Dictionary in objects_list:
		var oid: String = obj_dict["id"]
		objects[oid] = {"id": oid, "type": obj_dict["type"], "parent": obj_dict["parent"], "props": obj_dict["props"].duplicate(true)}
		order.append(oid)

static func from_dict(d: Dictionary) -> SceneModel:
	var model := SceneModel.new()
	model.load_from(d)
	return model
