class_name SceneBuilder
extends RefCounted

var problems: Array[String] = []

func build(model: SceneModel) -> Node:
	problems.clear()
	var root: Node = Node.new()
	root.name = "Szene"

	var id_to_node: Dictionary = {}

	for oid: String in model.order:
		var obj: Dictionary = model.get_object(oid)
		var type: String = obj["type"]

		if not _is_valid_type(type):
			problems.append("%s: Typ %s gibt es nicht" % [oid, type])
			var fallback: Node = Node.new()
			fallback.name = oid
			fallback.set_meta("hub_id", oid)
			fallback.set_meta("hub_type", type)
			id_to_node[oid] = fallback

			if obj["parent"].is_empty():
				root.add_child(fallback)
			else:
				var parent: Node = id_to_node.get(obj["parent"]) as Node
				if parent != null:
					parent.add_child(fallback)
			continue

		var node: Node = ClassDB.instantiate(type) as Node
		node.name = oid
		node.set_meta("hub_id", oid)
		node.set_meta("hub_type", type)
		id_to_node[oid] = node

		if obj["parent"].is_empty():
			root.add_child(node)
		else:
			var parent: Node = id_to_node.get(obj["parent"]) as Node
			if parent != null:
				parent.add_child(node)

	for oid: String in model.order:
		var obj: Dictionary = model.get_object(oid)
		var node: Node = id_to_node.get(oid) as Node
		if node == null:
			continue

		for key: String in obj["props"]:
			if _has_property(node, key):
				node.set(key, obj["props"][key])
			else:
				problems.append("%s: Eigenschaft %s gibt es nicht" % [oid, key])

	return root


func _has_property(node: Node, key: String) -> bool:
	for prop: Dictionary in node.get_property_list():
		if prop["name"] == key:
			return true
	return false


func _is_valid_type(type: String) -> bool:
	if not ClassDB.class_exists(type):
		return false
	if not ClassDB.can_instantiate(type):
		return false
	if not ClassDB.is_parent_class(type, "Node"):
		return false
	return true


static func find(root: Node, id: String) -> Node:
	if root == null:
		return null
	if root.get_meta("hub_id", "") == id:
		return root
	for child: Node in root.get_children():
		var found: Node = find(child, id)
		if found != null:
			return found
	return null
