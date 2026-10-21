extends "res://tests/base_test.gd"


func test_block() -> void:
	var text := "Hier:\n```json\n{\"a\": 1}\n```\nFertig"
	var result := ResponseParser.extract_json(text)
	check(result["ok"], "ok soll wahr sein")
	var data := result["data"] as Dictionary
	check_eq(data.get("a", -1), 1, "data[\"a\"] soll 1 sein")


func test_klammern() -> void:
	var text := "Antwort {\"b\": [1, 2]} Ende"
	var result := ResponseParser.extract_json(text)
	check(result["ok"], "ok soll wahr sein")
	var data := result["data"] as Dictionary
	check_eq(data.get("b", []).size(), 2, "data[\"b\"].size() soll 2 sein")


func test_kein_json() -> void:
	var text := "nur Text"
	var result := ResponseParser.extract_json(text)
	check(not result["ok"], "ok soll falsch sein")
	check_eq(result["error"], "kein_json", "error soll \"kein_json\" sein")


func test_ungueltig() -> void:
	var text := "{kaputt}"
	var result := ResponseParser.extract_json(text)
	check(not result["ok"], "ok soll falsch sein")
	check_eq(result["error"], "ungueltig", "error soll \"ungueltig\" sein")


func test_kein_objekt() -> void:
	var text := "```json\n[1, 2]\n```"
	var result := ResponseParser.extract_json(text)
	check(not result["ok"], "ok soll falsch sein")
	check_eq(result["error"], "kein_objekt", "error soll \"kein_objekt\" sein")
