extends "res://tests/base_test.gd"

var guard: PathGuard
var pre: ExportPreflight
var vorlagen_dir: String
var ausgabe_dir: String
var ziel: String


func setup() -> void:
	vorlagen_dir = ProjectSettings.globalize_path("user://test_export_preflight/vorlagen")
	ausgabe_dir = ProjectSettings.globalize_path("user://test_export_preflight/ausgabe")
	ziel = ProjectSettings.globalize_path("user://test_export_preflight/ausgabe/spiel.exe")

	DirAccess.make_dir_recursive_absolute(vorlagen_dir)
	DirAccess.make_dir_recursive_absolute(ausgabe_dir)

	guard = PathGuard.new()
	guard.add_root(ausgabe_dir)

	pre = ExportPreflight.new(guard, vorlagen_dir)


func teardown() -> void:
	var vorlagen := ProjectSettings.globalize_path("user://test_export_preflight/vorlagen")
	var ausgabe := ProjectSettings.globalize_path("user://test_export_preflight/ausgabe")

	DirAccess.remove_absolute(vorlagen + "/windows_release_x86_64.exe")
	DirAccess.remove_absolute(vorlagen + "/windows_debug_x86_64.exe")
	DirAccess.remove_absolute(ausgabe + "/spiel.exe")
	DirAccess.remove_absolute(ausgabe + "/spiel.txt")

	DirAccess.remove_absolute(ausgabe)
	DirAccess.remove_absolute(vorlagen)


func _vorlagen_anlegen() -> void:
	var dir := DirAccess.open(vorlagen_dir)
	for datei in ExportPreflight.TEMPLATE_FILES:
		var f := FileAccess.open(vorlagen_dir.path_join(datei), FileAccess.WRITE)
		if f:
			f.store_string("x")
			f.close()


func test_alles_da() -> void:
	_vorlagen_anlegen()
	var ergebnis := pre.check(ziel)
	check(ergebnis.is_ok(), "check(ziel) sollte ok sein")
	check_eq(ergebnis.data.get("output", ""), PathGuard.normalize(ziel), "data[\"output\"] muss gleich PathGuard.normalize(ziel)")


func test_vorlagen_fehlen() -> void:
	var probs := pre.problems(ziel)
	check_eq(probs, ["Exportvorlage fehlt: windows_release_x86_64.exe", "Exportvorlage fehlt: windows_debug_x86_64.exe"], "problems(ziel) bei fehlenden Vorlagen")


func test_pfad_verboten() -> void:
	_vorlagen_anlegen()
	var probs := pre.problems("C:/Windows/spiel.exe")
	check_eq(probs, ["Zielpfad ist nicht erlaubt: c:/Windows/spiel.exe"], "problems(verbotener Pfad)")


func test_endung() -> void:
	_vorlagen_anlegen()
	var fehlerziel := ProjectSettings.globalize_path("user://test_export_preflight/ausgabe/spiel.txt")
	var probs := pre.problems(fehlerziel)
	check_eq(probs, ["Die Zieldatei muss auf .exe enden"], "problems(.txt Datei)")


func test_ergebnis_fehler() -> void:
	var ergebnis := pre.check(ziel)
	check_eq(ergebnis.code, "dependency", "Code sollte dependency sein")
	check_eq(ergebnis.data.get("problems", []).size(), 2, "problems.size() muss 2 sein")


func test_standardordner() -> void:
	var ordner := ExportPreflight.default_templates_dir()
	check(ordner.contains("export_templates"), "default_templates_dir() muss 'export_templates' enthalten")
	var status := str(Engine.get_version_info()["status"])
	check(ordner.ends_with(status), "default_templates_dir() muss auf '%s' enden" % status)
