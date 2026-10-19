extends "res://tests/base_test.gd"

var map: ActionMap


func setup() -> void:
	map = ActionMap.new()
	map.add_action("springen")
	map.add_action("schiessen")


func test_gueltig() -> void:
	check(ActionMap.is_valid_input("taste:Space"), "taste:Space ist gültig")
	check(ActionMap.is_valid_input("taste:A"), "taste:A ist gültig")
	check(ActionMap.is_valid_input("maus:links"), "maus:links ist gültig")
	check(ActionMap.is_valid_input("maus:rechts"), "maus:rechts ist gültig")
	check(ActionMap.is_valid_input("maus:mitte"), "maus:mitte ist gültig")

	check(not ActionMap.is_valid_input("taste:Quatsch"), "taste:Quatsch ist ungültig")
	check(not ActionMap.is_valid_input("maus:oben"), "maus:oben ist ungültig")


func test_belegen() -> void:
	map = ActionMap.new()
	map.add_action("springen")

	var result := map.bind("springen", "taste:Space")
	check(result.is_ok(), "bind springen Space ist ok")

	var data := {"inputs": []}
	if map.actions.has("springen"):
		data.inputs = map.actions["springen"]
	check(data.inputs.size() == 1, "1 Eingabe nach bind")
	check(data.inputs[0] == "taste:Space", "Eingabe ist taste:Space")

	var result2 := map.bind("springen", "taste:Space")
	check(result2.is_ok(), "wiederholter bind ist ok")

	data.inputs = []
	if map.actions.has("springen"):
		data.inputs = map.actions["springen"]
	check(data.inputs.size() == 1, "weiterhin 1 Eingabe nach wiederholtem bind")


func test_fehler() -> void:
	var result := map.bind("laufen", "taste:A")
	check(not result.is_ok(), "bind nicht vorhandene Aktion ist nicht ok")
	check(result.code == "not_found", "Fehlercode ist not_found")

	result = map.bind("springen", "taste:Quatsch")
	check(not result.is_ok(), "bind ungültige Eingabe ist nicht ok")
	check(result.code == "invalid_argument", "Fehlercode ist invalid_argument")


func test_rueckwaerts() -> void:
	map = ActionMap.new()
	map.add_action("springen")
	map.add_action("schiessen")

	map.bind("springen", "taste:Space")
	map.bind("schiessen", "taste:Space")

	var result := map.actions_for("taste:Space")
	check(result.size() == 2, "zwei Aktionen für taste:Space")
	check(result[0] == "schiessen", "erste Aktion ist schiessen")
	check(result[1] == "springen", "zweite Aktion ist springen")


func test_speichern() -> void:
	map = ActionMap.new()
	map.add_action("springen")
	map.bind("springen", "taste:Space")

	var dict := map.to_dict()
	var loaded := ActionMap.from_dict(dict)

	var result := loaded.actions_for("taste:Space")
	check(result.size() == 1, "geladener Map hat eine Aktion für taste:Space")
	check(result[0] == "springen", "Aktion ist springen")
