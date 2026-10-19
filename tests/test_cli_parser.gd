extends "res://tests/base_test.gd"
class_name TestCliParser

## Tests für CliParser - Befehlszeilen-Parser

func test_werte() -> void:
	# Ganzzahl
	var v1: Variant = CliParser.parse_value("12")
	check_eq(v1, 12, "parse_value(\"12\") ist 12")
	check_eq(typeof(v1), TYPE_INT, "typeof parse_value(\"12\") == TYPE_INT")

	# Kommazahl
	var v2: Variant = CliParser.parse_value("2.5")
	check_eq(v2, 2.5, "parse_value(\"2.5\") ist 2.5")

	# Booleans
	var v3: Variant = CliParser.parse_value("true")
	check(v3 == true, "parse_value(\"true\") ist wahr")

	var v4: Variant = CliParser.parse_value("false")
	check(v4 == false, "parse_value(\"false\") ist falsch")

	# Text ohne Sonderzeichen
	var v5: Variant = CliParser.parse_value("Node2D")
	check_eq(v5, "Node2D", "parse_value(\"Node2D\") ist \"Node2D\"")

	# String in Anführungszeichen (wird zur Zeichenkette)
	var v6: Variant = CliParser.parse_value("\"42\"")
	check_eq(v6, "42", "parse_value(\\\"42\\\") ist \\\"42\\\"")
	check(typeof(v6) == TYPE_STRING, "typeof parse_value(\\\"42\\\") == TYPE_STRING")


func test_json() -> void:
	# JSON-Objekt mit Zahl
	var v1: Variant = CliParser.parse_value("{\"mass\": 2}")
	check(v1 is Dictionary, "parse_value(\"{\\\"mass\\\": 2}\") ist ein Dictionary")
	var dict: Dictionary = v1 as Dictionary
	check_eq(dict.get("mass", -1), 2, "dict[\"mass\"] == 2")

	# JSON-Array
	var v2: Variant = CliParser.parse_value("[1, 2]")
	check(v2 is Array, "parse_value(\"[1, 2]\") ist ein Array")
	var arr: Array = v2 as Array
	check_eq(arr.size(), 2, "arr.size() == 2")

	# Ungültiges JSON wird unverändert zurückgegeben
	var v3: Variant = CliParser.parse_value("{kaputt")
	check_eq(v3, "{kaputt", "parse_value(\"{kaputt\") ist \"{kaputt\"")


func test_befehl() -> void:
	var argv: PackedStringArray = PackedStringArray(["scene.add", "type=Node2D", "parent=", "props={\"mass\":2}"])
	var result: Dictionary = CliParser.parse(argv)

	check_eq(result["command"], "scene.add", "command == \"scene.add\"")
	check_eq(result["args"].get("type", ""), "Node2D", "args[\"type\"] == \"Node2D\"")
	check_eq(result["args"].get("parent", "NIX"), "", "args[\"parent\"] == \"\"")

	var props: Variant = result["args"].get("props", null)
	check(props is Dictionary, "args[\"props\"] ist ein Dictionary")
	var p: Dictionary = props as Dictionary
	check_eq(p.get("mass", -1), 2, "args[\"props\"][\"mass\"] == 2")

	check_eq(result["error"], "", "error == \"\"")


func test_gleichheitszeichen_im_wert() -> void:
	var argv: PackedStringArray = PackedStringArray(["x", "formel=a=b"])
	var result: Dictionary = CliParser.parse(argv)

	check_eq(result["args"].get("formel", ""), "a=b", "args[\"formel\"] == \"a=b\"")


func test_fehler() -> void:
	# Leere Liste
	var r1: Dictionary = CliParser.parse(PackedStringArray([]))
	check_eq(r1["error"], "Kein Befehl angegeben", "[] gibt Fehler bei leerer Liste")

	# Nur Parameter ohne Befehl
	var r2: Dictionary = CliParser.parse(PackedStringArray(["a=1"]))
	check_eq(r2["error"], "Erst den Befehl nennen, dann Parameter", "Fehler bei Parameter als erstes Element")

	# Parameter ohne '='
	var r3: Dictionary = CliParser.parse(PackedStringArray(["x", "ohne"]))
	check_eq(r3["error"], "Parameter ohne '=': ohne", "Fehler bei Parameter ohne Trennzeichen")

	# Leerer Parametername
	var r4: Dictionary = CliParser.parse(PackedStringArray(["x", "=1"]))
	check_eq(r4["error"], "Parametername fehlt", "Fehler bei leerem Parameternamen")

	# Doppelter Parametername
	var r5: Dictionary = CliParser.parse(PackedStringArray(["x", "a=1", "a=2"]))
	check_eq(r5["error"], "Parameter doppelt: a", "Fehler bei doppeltem Parametername")
