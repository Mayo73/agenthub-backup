extends RefCounted
class_name Prefab


var id: String = ""
var type: String = "Node2D"
var props: Dictionary = {}


func _init(prefab_id: String = "", node_type: String = "Node2D", base_props: Dictionary = {}) -> void:
	id = prefab_id
	type = node_type
	props = base_props.duplicate(true)


func instantiate(object_id: String, overrides: Dictionary = {}) -> Dictionary:
	var result_props: Dictionary = props.duplicate(true)
	for key in overrides:
		result_props[key] = overrides[key]
	return {
		"id": object_id,
		"type": type,
		"prefab": id,
		"props": result_props
	}


func overrides_of(instance: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	var instance_props: Dictionary = instance.get("props", {})
	for key in instance_props:
		if not props.has(key) or props[key] != instance_props[key]:
			result[key] = instance_props[key]
	return result


func to_dict() -> Dictionary:
	return {
		"id": id,
		"type": type,
		"props": props
	}


static func from_dict(d: Dictionary) -> Prefab:
	var prefab := Prefab.new()
	prefab.id = d.get("id", "")
	prefab.type = d.get("type", "Node2D")
	prefab.props = d.get("props", {}).duplicate(true)
	return prefab
