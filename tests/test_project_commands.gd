extends "res://tests/base_test.gd"

var guard: PathGuard
var model: SceneModel
var registry: CommandRegistry
var cmds: ProjectCommands


func setup() -> void:
	guard = PathGuard.new()
	guard.add_root("user://test_project_commands")
	model = SceneModel.new()
	registry = CommandRegistry.new()
	cmds = ProjectCommands.register_all(registry, ProjectStore.new(guard), model)


func teardown() -> void:
	var dir := DirAccess.open("user://test_project_commands")
	if dir:
		dir.remove("a.json")
		dir.remove_absolute("user://test_project_commands/a.json")
		dir.remove("b.json")
		dir.remove_absolute("user://test_project_commands/b.json")
		dir.remove("fehlt.json")
		dir.remove_absolute("user://test_project_commands/fehlt.json")
		if dir.dir_exists("anderswo"):
			dir.remove("anderswo/a.json")
		var err := dir.remove_absolute("user://test_project_commands/anderswo")
		print("teardown anderswo:", err)


func test_speichern_oeffnen() -> void:
	model.add_object("Node2D")

	var save_result := registry.execute("project.save", {"path": "user://test_project_commands/a.json", "name": "Demo"})
	check(save_result.is_ok(), "Speichern erfolgreich")

	# Modell leeren
	var neues_modell := SceneModel.new()
	model.load_from(neues_modell.to_dict())
	check_eq(model.order.size(), 0, "Modell nach Leerung leer")

	var open_result := registry.execute("project.open", {"path": "user://test_project_commands/a.json"})
	check(open_result.is_ok(), "Öffnen erfolgreich")

	var data := open_result.data as Dictionary
	check_eq(data["objects"], 1, "Anzahl Objekte 1")
	check(model.has_object("o1"), "Objekt o1 vorhanden")


func test_verbotener_pfad() -> void:
	var save_result := registry.execute("project.save", {"path": "user://anderswo/a.json", "name": "Test"})
	check(save_result.code == CommandResult.FORBIDDEN_PATH, "Verbotener Pfad erkannt")


func test_fehlt() -> void:
	var open_result := registry.execute("project.open", {"path": "user://test_project_commands/fehlt.json"})
	check(open_result.code == CommandResult.NOT_FOUND, "Fehlende Datei erkannt")


func test_info() -> void:
	model.add_object("Node2D")
	var save_result := registry.execute("project.save", {"path": "user://test_project_commands/b.json", "name": "Demo"})
	check(save_result.is_ok(), "Speichern erfolgreich")

	var info_result := registry.execute("project.info", {})
	check(info_result.is_ok(), "Info erfolgreich")
	var data := info_result.data as Dictionary
	check_eq(data["name"], "Demo", "Name stimmt")
