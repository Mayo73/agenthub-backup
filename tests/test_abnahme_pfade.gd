extends "res://tests/base_test.gd"

var guard: PathGuard

func setup() -> void:
	guard = PathGuard.new()
	guard.add_root("user://projekte/kisten")
	guard.add_root("user://export")


func test_erlaubt() -> void:
	var r1 := guard.check("user://projekte/kisten/szenen/start.json")
	check_eq(r1.code, "ok", "sollte erlaubten Pfad akzeptieren")

	var r2 := guard.check("user://export/kisten.exe")
	check_eq(r2.code, "ok", "sollte erlaubten Export-Pfad akzeptieren")


func test_ausserhalb() -> void:
	var r1 := guard.check("C:/Windows/system32/x.dll")
	check_eq(r1.code, "forbidden_path", "systempfad soll verboten sein")
	check(r1.message.contains("außerhalb der erlaubten Orte"), "Meldung muss 'außerhalb der erlaubten Orte' enthalten")

	var r2 := guard.check("user://projekte/anderes/a.json")
	check_eq(r2.code, "forbidden_path", "verzeigtes Projektverzeichnis soll verboten sein")


func test_ausbruch() -> void:
	var r := guard.check("user://projekte/kisten/../../geheim.txt")
	check_eq(r.code, "forbidden_path", "Pfad mit .. aus erlaubtem Bereich soll verboten sein")


func test_aehnlicher_name() -> void:
	var r := guard.check("user://export2/x.txt")
	check_eq(r.code, "forbidden_path", "Verzeichnis 'export2' (keine exakte Übereinstimmung) muss verboten sein")
