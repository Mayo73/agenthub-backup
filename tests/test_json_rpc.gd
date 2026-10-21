extends "res://tests/base_test.gd"


func test_anfrage() -> void:
	var text := '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}'
	var result := JsonRpc.parse(text)

	check(result.ok, "ok ist wahr")
	check_eq(result.method, "tools/list", "method ist tools/list")
	check(result.params is Dictionary and result.params.size() == 0, "params leer")
	check(not result.notification, "notification falsch")
	check_eq(result.id, 1, "id 1")


func test_params_als_liste() -> void:
	var result := JsonRpc.parse('{"jsonrpc": "2.0", "id": 2, "method": "x", "params": [1, 2]}')

	check(result.ok, "ok ist wahr")
	check(result.params is Dictionary and result.params.size() == 0, "params als Liste wird zu {}")


func test_benachrichtigung() -> void:
	var text := '{"jsonrpc": "2.0", "method": "tools/list"}'
	var result := JsonRpc.parse(text)

	check(result.ok, "ok ist wahr für Notification")
	check(result.notification, "notification wahr ohne id-Schlüssel")


func test_kaputt() -> void:
	# '{kaputt' wirft Exception bei parse_string - das wird abgefangen
	var result := JsonRpc.parse('{kaputt')

	check(not result.ok, "ok falsch bei ungültigem JSON")
	check_eq(result.error, JsonRpc.PARSE_ERROR, "error ist PARSE_ERROR")


func test_falsche_version() -> void:
	var text := '{"jsonrpc": "1.0", "id": 7, "method": "test"}'
	var result := JsonRpc.parse(text)

	check(not result.ok, "ok falsch bei falscher Version")
	check_eq(result.error, JsonRpc.INVALID_REQUEST, "error ist INVALID_REQUEST")
	check_eq(result.id, 7, "id 7")


func test_antwort() -> void:
	var json_str := JsonRpc.result(3, { "a": 1 })
	var parsed: Variant = JSON.parse_string(json_str) as Dictionary

	check(parsed != null, "JSON hat geparsed")
	check_eq(parsed.get("jsonrpc"), "2.0", "jsonrpc ist 2.0")
	check_eq(parsed.get("id"), 3, "id 3")
	check_eq(parsed.get("result").get("a"), 1, "result.a 1")


func test_fehler() -> void:
	var json_str := JsonRpc.error(4, JsonRpc.METHOD_NOT_FOUND, "Unbekannt")
	var parsed: Variant = JSON.parse_string(json_str) as Dictionary

	check(parsed != null, "JSON hat geparsed")
	check_eq(parsed.get("error").get("code"), -32601, "error.code -32601")
	check_eq(parsed.get("error").get("message"), "Unbekannt", "error.message Unbekannt")
