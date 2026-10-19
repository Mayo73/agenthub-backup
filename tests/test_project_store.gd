extends "res://tests/base_test.gd"

var guard: PathGuard
var store: ProjectStore


func setup() -> void:
	guard = PathGuard.new()
	guard.add_root("user://test_project_store")
	store = ProjectStore.new(guard)


func teardown() -> void:
	recursive_delete("user://test_project_store")


func recursive_delete(dir_path: String) -> void:
	var da := DirAccess.open(dir_path)
	if da == null:
		return
	da.list_dir_begin()
	var name := da.get_next()
	while name != "":
		if name == "." or name == "..":
			name = da.get_next()
			continue
		var full_path := dir_path + "/" + name
		if da.current_is_dir():
			recursive_delete(full_path)
		else:
			da.remove(name)
		name = da.get_next()
	da.list_dir_end()
	da = DirAccess.open(dir_path.get_base_dir())
	if da != null and dir_path.get_file() != "":
		da.remove(dir_path.get_file())


func test_speichern_und_oeffnen() -> void:
	var scene := SceneModel.new()
	var id1: String = scene.add_object("RigidBody")
	var id2: String = scene.add_object("RigidBody", id1)
	scene.set_property(id2, "mass", 2.0)

	var ergebnis: CommandResult = store.save("user://test_project_store/demo/projekt.json", "Demo", scene, ["physik"])
	check(ergebnis.is_ok(), "save erfolgreich")

	ergebnis = store.open("user://test_project_store/demo/projekt.json")
	check(ergebnis.is_ok(), "open erfolgreich")
	var data: Dictionary = ergebnis.data as Dictionary

	check_eq(data["name"], "Demo", "Name korrekt")
	var loaded_scene: SceneModel = data["scene"] as SceneModel
	check_eq(loaded_scene.order.size(), 2, "Szene hat zwei Objekte")
	check_eq(loaded_scene.get_property("o2", "mass"), 2.0, "Eigenschaft mass=2.0 korrekt geladen")
	check_eq(data["modules"], ["physik"], "ModuleArray korrekt")


func test_verboten() -> void:
	var scene := SceneModel.new()
	var ergebnis: CommandResult = store.save("user://anderswo/p.json", "Demo", scene, [])
	check(ergebnis.code == "forbidden_path", "Verbotener Pfad wird abgelehnt")
	check(FileAccess.file_exists("user://anderswo/p.json") == false, "Datei wurde nicht erstellt")


func test_fehlt() -> void:
	var ergebnis: CommandResult = store.open("user://test_project_store/gibtsnicht.json")
	check(ergebnis.code == "not_found", "Fehlende Projektdatei wird erkannt")


func test_format() -> void:
	DirAccess.make_dir_recursive_absolute("user://test_project_store")
	var file := FileAccess.open("user://test_project_store/format_test.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"format": 99, "name": "x", "scene": {}, "modules": []}))
	file.close()

	var ergebnis: CommandResult = store.open("user://test_project_store/format_test.json")
	check(ergebnis.code == "incompatible", "Falsches Format wird erkannt")
	check("Projektformat 99 wird nicht unterstützt" in ergebnis.message, "Meldung enthält korrekten Text")
	var da := DirAccess.open("user://test_project_store")
	if da != null:
		da.remove("format_test.json")


func test_kaputt() -> void:
	DirAccess.make_dir_recursive_absolute("user://test_project_store")
	var file := FileAccess.open("user://test_project_store/kaputt.json", FileAccess.WRITE)
	file.store_string("kaputt")
	file.close()

	var ergebnis: CommandResult = store.open("user://test_project_store/kaputt.json")
	check(ergebnis.code == "invalid_argument", "Korrupte Datei wird erkannt")

	var da := DirAccess.open("user://test_project_store")
	if da != null:
		da.remove("kaputt.json")
