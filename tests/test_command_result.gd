extends "res://tests/base_test.gd"


func test_erfolg() -> void:
	var r := CommandResult.success({"id": "o1"}, "angelegt")
	check(r.is_ok(), "Erfolg ist ok")
	check_eq(r.to_dict(), {"ok": true, "code": "ok", "message": "angelegt", "data": {"id": "o1"}}, "als Dictionary")


func test_fehler() -> void:
	var r := CommandResult.error(CommandResult.NOT_FOUND, "Objekt o9 gibt es nicht")
	check(not r.is_ok(), "Fehler ist nicht ok")
	check_eq(r.to_dict()["code"], "not_found", "Fehlercode")
	check_eq(r.to_dict()["ok"], false, "ok falsch")
