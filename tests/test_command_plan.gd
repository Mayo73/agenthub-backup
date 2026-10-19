extends "res://tests/base_test.gd"

var registry: CommandRegistry
var model: SceneModel


func setup() -> void:
	registry = CommandRegistry.new()
	model = SceneModel.new()
	SceneCommands.register_all(registry, model)


func test_json_block() -> void:
	var text := "Hier:\n```json\n[{\"command\": \"x\"}]\n```\n"
	var result: String = CommandPlan.extract_json(text)
	check_eq(result, "[{\"command\": \"x\"}]")


func test_lesen() -> void:
	var text := "[{\"command\": \"scene.list\", \"args\": {\"parent\": \"\"}}]"
	var ergebnis: CommandResult = CommandPlan.parse(text)

	check(ergebnis.is_ok(), "parse sollte ok sein")
	if ergebnis.is_ok():
		var data: Dictionary = ergebnis.data as Dictionary
		check_eq(data.get("steps", []).size(), 1)


func test_ungueltig() -> void:
	var text := "keine Ahnung"
	var ergebnis: CommandResult = CommandPlan.parse(text)

	check(not ergebnis.is_ok(), "sollte invalid_argument sein")
	if not ergebnis.is_ok():
		check_eq(ergebnis.code, "invalid_argument")


func test_unbekannt() -> void:
	var steps := [{"command": "zaubern", "args": {}}] as Array[Dictionary]
	var ergebnis: CommandResult = CommandPlan.run(registry, steps)

	check(not ergebnis.is_ok(), "sollte invalid_argument sein")
	if not ergebnis.is_ok():
		check(ergebnis.message.contains("Schritt 1: Befehl zaubern gibt es nicht"), "Meldung stimmt")
		check_eq(model.order.size(), 0, "kein Befehl ausgeführt")


func test_ausfuehren() -> void:
	var steps := [
		{"command": "scene.add", "args": {"type": "Node2D", "parent": "", "props": {}}},
		{"command": "scene.add", "args": {"type": "Node3D", "parent": "", "props": {}}}
	] as Array[Dictionary]

	var ergebnis: CommandResult = CommandPlan.run(registry, steps)
	check(ergebnis.is_ok(), "beide Befehle sollten ok sein")
	if ergebnis.is_ok():
		var data: Dictionary = ergebnis.data as Dictionary
		check_eq(data.get("done", 0), 2)
		check_eq(model.order.size(), 2)


func test_abbruch() -> void:
	model.add_object("Node2D", "", {})

	var steps := [
		{"command": "scene.add", "args": {"type": "Node2D", "parent": "", "props": {}}},
		{"command": "scene.remove", "args": {"id": "o9"}},
		{"command": "scene.add", "args": {"type": "Node3D", "parent": "", "props": {}}}
	] as Array[Dictionary]

	var ergebnis: CommandResult = CommandPlan.run(registry, steps)
	check(not ergebnis.is_ok(), "sollte not_found beim zweiten Schritt")
	if not ergebnis.is_ok():
		check_eq(ergebnis.code, "not_found")
		var data: Dictionary = ergebnis.data
		check_eq(data.get("done", 0), 1)
		check_eq(model.order.size(), 2, "ein Objekt wurde hinzugefügt")
