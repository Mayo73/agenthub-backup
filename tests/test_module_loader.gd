extends "res://tests/base_test.gd"
## Tests für ModuleLoader.

var test_dir := "user://test_module_loader/"


func setup() -> void:
	var dir := DirAccess.open(test_dir)
	if dir == null:
		DirAccess.make_dir_recursive_absolute(test_dir)


func teardown() -> void:
	remove_files_and_directory(test_dir)


func remove_files_and_directory(path: String) -> void:
	var file_pattern := path + "/*"
	var files := DirAccess.get_files_at(path)
	for f in files:
		var pfad := path + f
		DirAccess.remove_absolute(pfad)
	var directories := DirAccess.get_directories_at(path)
	for d in directories:
		remove_files_and_directory(path + d + "/")
	DirAccess.remove_absolute(path)


func test_beispiel_lesen() -> void:
	var ergebnis: CommandResult = ModuleLoader.read_manifest("res://modules/beispiel/manifest.json")
	check(ergebnis.is_ok(), "Manifest sollte gelesen werden können")
	var manifest := ergebnis.data.get("manifest") as ModuleManifest
	check_eq(manifest.id, "beispiel", "id stimmt")
	check_eq(manifest.engine_api, 1, "engine_api ist 1")


func test_fehlt() -> void:
	var ergebnis: CommandResult = ModuleLoader.read_manifest("user://test_module_loader/gibtsnicht/manifest.json")
	check(not ergebnis.is_ok(), "Fehlende Datei sollte Fehler melden")
	check_eq(ergebnis.code, "not_found", "Fehlercode ist not_found")


func test_kaputt() -> void:
	DirAccess.make_dir_recursive_absolute("user://test_module_loader/kaputt/")
	var datei := FileAccess.open("user://test_module_loader/kaputt/manifest.json", FileAccess.WRITE)
	datei.store_string("[\"nicht\", \"json\"]")
	datei.close()
	var ergebnis: CommandResult = ModuleLoader.read_manifest("user://test_module_loader/kaputt/manifest.json")
	check(not ergebnis.is_ok(), "Kaputtes JSON sollte Fehler melden")
	check_eq(ergebnis.code, "invalid_argument", "Fehlercode ist invalid_argument")


func test_ordner_laden() -> void:
	var registry: ModuleRegistry = ModuleRegistry.new()
	DirAccess.make_dir_recursive_absolute("user://test_module_loader/a/")
	DirAccess.make_dir_recursive_absolute("user://test_module_loader/b/")
	var f1 := FileAccess.open("user://test_module_loader/a/manifest.json", FileAccess.WRITE)
	f1.store_string("{\"id\": \"a\", \"name\": \"Modul A\", \"version\": \"1.0.0\", \"engine_api\": 1, \"requires\": [], \"optional\": true, \"capabilities\": []}")
	f1.close()
	var f2 := FileAccess.open("user://test_module_loader/b/manifest.json", FileAccess.WRITE)
	f2.store_string("{\"id\": \"b\", \"name\": \"Modul B\", \"version\": \"1.0.0\", \"engine_api\": 2, \"requires\": [], \"optional\": true, \"capabilities\": []}")
	f2.close()
	var ergebnis: Array[String] = ModuleLoader.load_dir("user://test_module_loader", registry)
	check_eq(ergebnis.size(), 2, "zwei Ordner")
	check("a: geladen" in ergebnis, "Modul a sollte geladen werden")
	var fehlermeldung := "b: Modul b braucht Engine-Schnittstelle 2, vorhanden ist 1"
	check(fehlermeldung in ergebnis, "Modul b sollte fehlgeschlagen melden")
	check(registry.modules.has("a"), "registry.modules hat 'a'")
	check(not registry.modules.has("b"), "registry.modules hat kein 'b'")


func test_modulordner() -> void:
	var registry := ModuleRegistry.new()
	var ergebnis: Array[String] = ModuleLoader.load_dir("res://modules", registry)
	check("beispiel: geladen" in ergebnis, "Beispielmodul sollte geladen werden")
