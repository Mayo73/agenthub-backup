extends "res://tests/base_test.gd"

var model: SceneModel
var coord: WriteCoordinator
var registry: CommandRegistry


func setup() -> void:
	model = SceneModel.new()
	model.add_object("RigidBody2D", "", {"mass": 1.0})
	coord = WriteCoordinator.new(model)
	registry = CommandRegistry.new()
	WriteCommands.register_all(registry, coord)


func test_setzen() -> void:
	var result := registry.execute("write.set", {
		"id": "o1",
		"key": "mass",
		"value": 2.0,
		"base": 0,
		"author": "gui"
	})
	check(result.code == CommandResult.CODE_OK, "Befehl erfolgreich")
	check_eq(model.get_property("o1", "mass"), 2.0, "Eigenschaft gesetzt")


func test_konflikt() -> void:
	var result1 := registry.execute("write.set", {
		"id": "o1",
		"key": "mass",
		"value": 2.0,
		"base": 0,
		"author": "gui"
	})
	check(result1.code == CommandResult.CODE_OK, "Erste Änderung erfolgreich")

	var result2 := registry.execute("write.set", {
		"id": "o1",
		"key": "mass",
		"value": 3.0,
		"base": 0,
		"author": "agent"
	})
	check(result2.code == CommandResult.CONFLICT, "Zweiter Versuch als Konflikt")
	check_eq(model.get_property("o1", "mass"), 2.0, "Modell beim ersten Wert")


func test_revision() -> void:
	var _result := registry.execute("write.set", {
		"id": "o1",
		"key": "mass",
		"value": 3.0,
		"base": 0,
		"author": "gui"
	})
	var rev_result := registry.execute("write.revision", {})
	check_eq(rev_result.data["revision"], 1, "Revision erhöht")


func test_verlauf() -> void:
	registry.execute("write.set", {
		"id": "o1",
		"key": "mass",
		"value": 2.0,
		"base": 0,
		"author": "gui"
	})
	registry.execute("write.set", {
		"id": "o1",
		"key": "mass",
		"value": 3.0,
		"base": 1,
		"author": "agent"
	})
	var hist_result := registry.execute("write.history", {"id": "o1"})
	check_eq(hist_result.data["entries"].size(), 2, "Zwei Einträge im Verlauf")
