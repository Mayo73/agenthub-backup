extends "res://tests/base_test.gd"

var builder: SceneBuilder
var model: SceneModel


func setup() -> void:
	builder = SceneBuilder.new()
	model = SceneModel.new()


func teardown() -> void:
	if builder != null:
		builder = null
	if model != null:
		model = null


func find_and_free(node: Node) -> bool:
	for child: Node in node.get_children():
		find_and_free(child)
	node.free()
	return true


func test_position_2d() -> void:
	model.add_object("Node2D", "", {"position": Vector2(3, 4)})

	var root: Node = builder.build(model)
	var result := StateQuery.query(root, "o1")
	check(result.is_ok(), "query ok für existierenden Knoten")

	var data: Dictionary = result.data
	check_eq(data["position"], [3.0, 4.0], "position ist [3.0, 4.0]")
	check_eq(data["type"], "Node2D", "type ist Node2D")
	check(data["visible"] == true, "visible ist wahr")

	find_and_free(root)


func test_geschwindigkeit() -> void:
	model.add_object("RigidBody2D", "", {"linear_velocity": Vector2(1, -2)})

	var root: Node = builder.build(model)
	var result := StateQuery.query(root, "o1")
	check(result.is_ok(), "query ok")

	var data: Dictionary = result.data
	check_eq(data["velocity"], [1.0, -2.0], "velocity ist [1.0, -2.0]")

	find_and_free(root)


func test_3d() -> void:
	model.add_object("Node3D", "", {"position": Vector3(1, 2, 3)})

	var root: Node = builder.build(model)
	var result := StateQuery.query(root, "o1")
	check(result.is_ok(), "query ok")

	var data: Dictionary = result.data
	check_eq(data["position"], [1.0, 2.0, 3.0], "position ist [1.0, 2.0, 3.0]")

	find_and_free(root)


func test_fehlt() -> void:
	model.add_object("Node2D", "", {})

	var root: Node = builder.build(model)
	var result := StateQuery.query(root, "o9")
	check(result.code == CommandResult.NOT_FOUND, "Code ist not_found")
	check(result.message == "Objekt o9 gibt es nicht", "Meldung ist korrekt")

	find_and_free(root)


func test_baum() -> void:
	var o1_id: String = model.add_object("Node2D", "", {"name": "o1"})
	var o2_id: String = model.add_object("Sprite2D", o1_id, {"name": "o2"})

	var root: Node = builder.build(model)
	var result := StateQuery.tree(root)

	check(result.size() == 2, "tree hat zwei Einträge")
	check_eq(result[0]["id"], "o1", "erster Eintrag id ist o1")
	check_eq(result[0]["type"], "Node2D", "erster Eintrag type ist Node2D")
	check_eq(result[0]["parent"], "", "erster Eintrag parent ist leer")

	check_eq(result[1]["id"], "o2", "zweiter Eintrag id ist o2")
	check_eq(result[1]["type"], "Sprite2D", "zweiter Eintrag type ist Sprite2D")
	check_eq(result[1]["parent"], "o1", "zweiter Eintrag parent ist o1")

	find_and_free(root)


func test_vec() -> void:
	var v1 := StateQuery.vec(Vector2(1, 2))
	check_eq(v1, [1.0, 2.0], "vec(Vector2(1, 2)) ist [1.0, 2.0]")

	var v2 := StateQuery.vec("x")
	check_eq(v2, [], "vec(\"x\") ist []")
