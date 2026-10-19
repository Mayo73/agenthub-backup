extends "res://tests/base_test.gd"

var registry: CommandRegistry
var runner: CliRunner


func setup() -> void:
	registry = CommandRegistry.new()

	# Registriere math.add Befehl mit Handler der Summe berechnet
	registry.register(
		"math.add",
		"Auf zwei Zahlen addieren",
		{"a": "number", "b": "number"},
		func(args: Dictionary) -> CommandResult:
			var sum: float = args["a"] + args["b"]
			return CommandResult.success({"sum": sum})
	)

	runner = CliRunner.new(registry)


func _parse_json_output(output_string: String) -> Dictionary:
	return JSON.parse_string(output_string) as Dictionary


func test_ausfuehren() -> void:
	var output: Dictionary = runner.run(["math.add", "a=2", "b=3"])
	var exit_code: int = output["exit_code"]
	var parsed_output: Dictionary = _parse_json_output(output["output"])

	check_eq(exit_code, 0, "Exit-Code sollte OK sein")
	check(parsed_output.get("ok", false), "ok soll wahr sein")
	check_eq(parsed_output.get("code", ""), "ok", "code soll ok sein")
	check_eq(parsed_output.get("data", {}).get("sum", -1), 5, "Summe soll 5 sein")


func test_unbekannt() -> void:
	var output: Dictionary = runner.run(["gibts.nicht"])
	var exit_code: int = output["exit_code"]
	var parsed_output: Dictionary = _parse_json_output(output["output"])

	check_eq(exit_code, 1, "Exit-Code sollte ERROR sein für unbekannten Befehl")
	check_eq(parsed_output.get("code", ""), "unknown_command", "code soll unknown_command sein")


func test_falscher_typ() -> void:
	var output: Dictionary = runner.run(["math.add", "a=2", "b=x"])
	var exit_code: int = output["exit_code"]
	var parsed_output: Dictionary = _parse_json_output(output["output"])

	check_eq(exit_code, 1, "Exit-Code sollte ERROR sein für falschen Typ")
	check_eq(parsed_output.get("code", ""), "invalid_argument", "code soll invalid_argument sein")
	check("Parameter b muss number sein" in parsed_output.get("message", ""), "Message soll Fehlertyp von b enthalten")


func test_aufruf_falsch() -> void:
	var output: Dictionary = runner.run([])
	var exit_code: int = output["exit_code"]
	var parsed_output: Dictionary = _parse_json_output(output["output"])

	check_eq(exit_code, 2, "Exit-Code sollte USAGE sein bei leerer Eingabe")
	check_eq(parsed_output.get("code", ""), "invalid_argument", "code soll invalid_argument sein")
	check("Kein Befehl angegeben" in parsed_output.get("message", ""), "Message soll 'Kein Befehl angegeben' enthalten")


func test_hilfe() -> void:
	var output: Dictionary = runner.run(["help"])
	var exit_code: int = output["exit_code"]
	var parsed_output: Dictionary = _parse_json_output(output["output"])

	check_eq(exit_code, 0, "Exit-Code sollte OK sein für help")
	check(parsed_output.get("ok", false), "ok soll wahr sein")
	var cmds := parsed_output.get("data", {}).get("commands", []) as Array
	check_eq(cmds.size(), 1, "Es soll genau ein Befehl registriert sein")
	check_eq(cmds[0].get("name", ""), "math.add", "Erster Befehl soll math.add sein")
