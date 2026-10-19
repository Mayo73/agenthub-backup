extends "res://tests/base_test.gd"

var model: SceneModel
var session: EditorSession
var registry: CommandRegistry


func setup() -> void:
	model = SceneModel.new()
	model.add_object("Node2D", "", {"name": "Welt"})  # o1
	model.add_object("Sprite2D", "o1", {"name": "Spieler"})  # o2
	session = EditorSession.new(model)
	registry = CommandRegistry.new()
	EditorCommands.register_all(registry, session)


func test_auswahl() -> void:
	var result := registry.execute("editor.select", {"id": "o2"})
	check(result.is_ok(), "editor.select soll für o2 erfolgreich sein")
	check(session.selected == "o2", "Selected soll o2 sein")

	var sel_result := registry.execute("editor.selection", {})
	check(sel_result.is_ok(), "editor.selection soll erfolgreich sein")
	var data: Dictionary = sel_result.data as Dictionary
	check_eq(data["selected"], "o2", "data['selected'] soll o2 sein")


func test_unbekannt() -> void:
	var result := registry.execute("editor.select", {"id": "o9"})
	check(not result.is_ok(), "Soll fehlschlagen bei unbekanntem Objekt")
	check(result.code == CommandResult.NOT_FOUND, "Code soll NOT_FOUND sein")


func test_suche() -> void:
	var result := registry.execute("editor.search", {"text": "spieler"})
	check(result.is_ok(), "Suche soll erfolgreich sein")
	var data: Dictionary = result.data as Dictionary
	var ids: Array[String] = data["ids"]
	check(ids.size() == 1, "Soll genau einen Treffer haben")
	check(ids[0] == "o2", "Treffer soll o2 sein")


func test_pfad() -> void:
	var result := registry.execute("editor.path", {"id": "o2"})
	check(result.is_ok(), "Pfadabfrage soll erfolgreich sein")
	var data: Dictionary = result.data as Dictionary
	var path: Array[String] = data["path"]
	check(path.size() == 2, "Pfad soll zwei Elemente haben")
	check(path[0] == "o1", "Erstes Element soll o1 (Eltern) sein")
	check(path[1] == "o2", "Zweites Element soll o2 sein")

	var not_found_result := registry.execute("editor.path", {"id": "o9"})
	check(not not_found_result.is_ok(), "Soll fehlschlagen bei unbekanntem Objekt")
	check(not_found_result.code == CommandResult.NOT_FOUND, "Code soll NOT_FOUND sein")
