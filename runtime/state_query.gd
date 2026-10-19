class_name StateQuery
extends RefCounted

static func vec(v: Variant) -> Array:
	if v is Vector2:
		return [float(v.x), float(v.y)]
	if v is Vector3:
		return [float(v.x), float(v.y), float(v.z)]
	return []


static func object_state(node: Node) -> Dictionary:
	var result: Dictionary = {
		"id": str(node.get_meta("hub_id", "")),
		"type": node.get_class(),
		"name": str(node.name)
	}

	if node is Node2D:
		result["position"] = vec(node.position)
		result["rotation"] = node.rotation_degrees

	if node is Node3D:
		result["position"] = vec(node.position)
		result["rotation"] = vec(node.rotation_degrees)

	if node is RigidBody2D:
		result["velocity"] = vec(node.linear_velocity)

	if node is RigidBody3D:
		result["velocity"] = vec(node.linear_velocity)

	if node is CharacterBody2D:
		result["velocity"] = vec(node.velocity)

	if node is CharacterBody3D:
		result["velocity"] = vec(node.velocity)

	if node is CanvasItem:
		result["visible"] = node.visible

	if node is Node3D:
		result["visible"] = node.visible

	return result


static func query(root: Node, id: String) -> CommandResult:
	var node: Node = SceneBuilder.find(root, id)
	if node == null:
		return CommandResult.error(CommandResult.NOT_FOUND, "Objekt %s gibt es nicht" % [id])
	return CommandResult.success(object_state(node))


static func tree(root: Node) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	_collect_tree_nodes(root, result)
	return result


static func _collect_tree_nodes(node: Node, result: Array[Dictionary]) -> void:
	var hub_id: String = node.get_meta("hub_id", "")
	if not hub_id.is_empty():
		var hub_type: String = node.get_meta("hub_type", "")
		var parent_id: String = ""
		var parent_node: Node = node.get_parent()
		if parent_node != null:
			parent_id = parent_node.get_meta("hub_id", "")
		result.append({"id": hub_id, "type": hub_type, "parent": parent_id})

	for child: Node in node.get_children():
		_collect_tree_nodes(child, result)
