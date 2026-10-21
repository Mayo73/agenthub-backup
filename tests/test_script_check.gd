extends "res://tests/base_test.gd"

const VALID := "extends Node\n\nfunc f() -> int:\n\treturn 1\n"
const NO_COLON := "extends Node\nfunc f() -> void\n\tpass\n"


func test_gueltig() -> void:
	var result: CommandResult = ScriptCheck.check(VALID)
	check(result.is_ok(), "gültiges Script wird angenommen")
	check_eq(result.data.get("base", ""), "Node", "Basisklasse ist Node")


func test_leer() -> void:
	check_eq(ScriptCheck.check("   ").code, "invalid_argument", "leeres Script abgelehnt")


func test_leerzeichen() -> void:
	var problems: Array[String] = ScriptCheck.quick_problems("extends Node\nfunc f() -> void:\n    pass\n")
	check(problems.has("Zeile 3: mit Tabs einrücken, nicht mit Leerzeichen"), "Leerzeichen gemeldet")


func test_doppelpunkt() -> void:
	var problems: Array[String] = ScriptCheck.quick_problems(NO_COLON)
	check(problems.has("Zeile 2: Doppelpunkt fehlt"), "fehlender Doppelpunkt gemeldet")


func test_klammern() -> void:
	var result: CommandResult = ScriptCheck.check("extends Node\nfunc f() -> void:\n\tprint((1)\n")
	check_eq(result.code, "invalid_argument", "unausgeglichene Klammern abgelehnt")
	var problems: Array = result.data.get("problems", [])
	check(problems.has("Klammern sind nicht ausgeglichen"), "Klammern gemeldet")


func test_wiederherstellen() -> void:
	var checker := ScriptCheck.new()
	check(checker.apply(VALID).is_ok(), "gültiger Stand übernommen")
	var result: CommandResult = checker.apply(NO_COLON)
	check(not result.is_ok(), "fehlerhafter Stand abgelehnt")
	check_eq(result.data.get("restored", ""), VALID, "letzter gültiger Stand zurückgegeben")
	check_eq(checker.last_good, VALID, "last_good unverändert")
