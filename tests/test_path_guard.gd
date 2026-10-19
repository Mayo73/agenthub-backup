extends "res://tests/base_test.gd"

var guard: PathGuard = PathGuard.new()


func setup() -> void:
	guard = PathGuard.new()
	guard.add_root("C:\\Spiele\\demo")
	guard.add_root("user://exporte")


func test_normalisieren() -> void:
	var path: String = PathGuard.normalize("C:\\Spiele\\demo\\..\\demo\\szene.json")
	check_eq(path, "c:/Spiele/demo/szene.json", "Backslashes und .. normalisieren")
	path = PathGuard.normalize("C:/Spiele/demo/")
	check_eq(path, "c:/Spiele/demo", "abschließenden Slash entfernen")


func test_erlaubt() -> void:
	check(guard.is_allowed("C:/Spiele/demo/szenen/a.json"), "Unterverzeichnis erlaubt")
	check(guard.is_allowed("C:/Spiele/demo"), "Wurzel selbst erlaubt")
	check(guard.is_allowed("user://exporte/spiel.exe"), "anderer Root erlaubt")


func test_ausbruch() -> void:
	check(not guard.is_allowed("C:/Spiele/demo/../../Windows/x.dll"), "Ausbruch verhindert")


func test_praefix() -> void:
	check(not guard.is_allowed("C:/Spiele/demo2/a.json"), "Präfix-Trick verhindert")


func test_pruefen() -> void:
	var result: CommandResult = guard.check("D:/fremd/a.txt")
	check_eq(result.code, "forbidden_path", "Code forbidden_path")
	check(result.message.begins_with("Pfad liegt außerhalb der erlaubten Orte: d:/fremd/a.txt"), "Meldung korrekt")

	result = guard.check("C:/Spiele/demo/a.txt")
	check(result.is_ok(), "erlaubter Pfad ok")
	check_eq(result.data["path"], "c:/Spiele/demo/a.txt", "data.path korrekt")
