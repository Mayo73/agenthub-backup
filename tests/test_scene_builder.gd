extends "res://tests/base_test.gd"

var builder: SceneBuilder
var model: SceneModel


func setup() -> void:
	builder = SceneBuilder.new()
	model = SceneModel.new()


func teardown() -> void:
	if builder != null:
		builder = null
	# model ist ein RefCounted und wird automatisch garbage collected
	if model != null:
		model = null


func test_baum() -> void:
	model.add_object("Node2D", "", {"name": "o1"})
	var o2: String = model.add_object("Sprite2D", "o1")

	var root: Node = builder.build(model)
	check(root.get_child_count() == 1, "Wurzel hat 1 Kind")
	var child1: Node = root.get_child(0)
	check(child1.name == "o1", "Kind heißt o1")
	check(child1.get_meta("hub_id") == "o1", "hub_id ist o1")

	check(child1.get_child_count() == 1, "o1 hat 1 Kind")
	var child2: Node = child1.get_child(0)
	check(child2.name == "o2", "Kind von o1 heißt o2")
	check(child2 is Sprite2D, "Kind ist Sprite2D")

	check(find_and_free(root), "Wurzel frei gegeben")


func test_eigenschaften() -> void:
	model.add_object("Node2D", "", {"visible": false, "z_index": 3})

	var root: Node = builder.build(model)
	var node: Node = SceneBuilder.find(root, "o1")
	check(node.visible == false, "visible ist false")
	check(node.z_index == 3, "z_index ist 3")

	check(find_and_free(root), "Wurzel frei gegeben")


func test_unbekannter_typ() -> void:
	model.objects["o1"] = {"id": "o1", "type": "GibtEsNicht", "parent": "", "props": {}}
	model.order = ["o1"]

	var root: Node = builder.build(model)
	check(SceneBuilder.find(root, "o1") != null, "Knoten vorhanden trotz unbekanntem Typ")
	check(builder.problems.size() == 1, "ein Problem gemeldet")
	var found: bool = false
	for p: String in builder.problems:
		if "o1: Typ GibtEsNicht gibt es nicht" in p:
			found = true
			break
	check(found, "richtige Fehlermeldung")

	check(find_and_free(root), "Wurzel frei gegeben")


func test_unbekannte_eigenschaft() -> void:
	model.add_object("Node2D", "", {"fluegel": 2})

	var root: Node = builder.build(model)
	check(SceneBuilder.find(root, "o1") != null, "Knoten vorhanden")
	check(builder.problems.size() == 1, "ein Problem gemeldet")
	var found: bool = false
	for p: String in builder.problems:
		if "o1: Eigenschaft fluegel gibt es nicht" in p:
			found = true
			break
	check(found, "richtige Fehlermeldung")

	check(find_and_free(root), "Wurzel frei gegeben")


func test_kein_node() -> void:
	model.objects["o1"] = {"id": "o1", "type": "Resource", "parent": "", "props": {}}
	model.order = ["o1"]

	var root: Node = builder.build(model)
	check(SceneBuilder.find(root, "o1") != null, "Platzhalter-Knoten auch für nicht-Node-Typen erstellt")
	check(builder.problems.size() == 1, "ein Problem gemeldet")
	var found: bool = false
	for p: String in builder.problems:
		if "o1: Typ Resource gibt es nicht" in p:
			found = true
			break
	check(found, "richtige Fehlermeldung für Resource")

	check(find_and_free(root), "Wurzel frei gegeben")


func test_reihenfolge() -> void:
	model.add_object("Node2D", "", {"name": "o1"})
	model.add_object("Node2D", "", {"name": "o2"})
	model.add_object("Node2D", "", {"name": "o3"})

	var root: Node = builder.build(model)
	check(root.get_child_count() == 3, "Wurzel hat 3 Kinder")
	check(root.get_child(0).name == "o1", "erstes Kind heißt o1")
	check(root.get_child(1).name == "o2", "zweites Kind heißt o2")
	check(root.get_child(2).name == "o3", "drittes Kind heißt o3")

	check(find_and_free(root), "Wurzel frei gegeben")


func find_and_free(node: Node) -> bool:
	for child: Node in node.get_children():
		find_and_free(child)
	node.free()
	return true
