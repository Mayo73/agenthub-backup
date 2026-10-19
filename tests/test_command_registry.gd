extends "res://tests/base_test.gd"

var registry: CommandRegistry


func setup() -> void:
	registry = CommandRegistry.new()
	var add_handler := Callable(self, "_add_handler")
	registry.register(
		"math.add",
		"Addiert zwei Zahlen.",
		{"a": "number", "b": "number"},
		add_handler
	)


func _add_handler(args: Dictionary) -> CommandResult:
	var sum: float = args["a"] + args["b"]
	return CommandResult.success({"sum": sum}, "Ergebnis: %s" % sum)


func test_ausfuehren() -> void:
	var result := registry.execute("math.add", {"a": 2, "b": 3.5})
	check(result.is_ok(), "Befehl sollte erfolgreich sein")
	check_eq(result.data["sum"], 5.5, "Summe soll 5.5 sein")


func test_unbekannt() -> void:
	var result := registry.execute("gibts.nicht", {})
	check(not result.is_ok(), "Ungültiger Befehl soll fehlschlagen")
	check_eq(result.code, "unknown_command", "Code soll unknown_command sein")
	check(result.message.contains("Unbekannter Befehl: gibts.nicht"), "Meldung soll unbekannten Befehl nennen")


func test_parameter_fehlt() -> void:
	var result := registry.execute("math.add", {"a": 1})
	check(not result.is_ok(), "Fehlerhafte Ausführung soll fehlschlagen")
	check_eq(result.code, "invalid_argument", "Code soll invalid_argument sein")
	check(result.message.contains("Parameter fehlt: b"), "Meldung soll fehlenden Parameter nennen")


func test_falscher_typ() -> void:
	var result := registry.execute("math.add", {"a": 1, "b": "x"})
	check(not result.is_ok(), "Fehlerhafte Ausführung soll fehlschlagen")
	check_eq(result.code, "invalid_argument", "Code soll invalid_argument sein")
	check(result.message.contains("Parameter b muss number sein"), "Meldung soll falschen Typ benennen")


func test_typen() -> void:
	check(registry.type_matches("x", "string"), "string sollte String erkennen")
	check(registry.type_matches(true, "bool"), "bool sollte bool erkennen")
	check(registry.type_matches({}, "dict"), "dict sollte Dictionary erkennen")
	check(registry.type_matches([], "array"), "array sollte Array erkennen")
	check(registry.type_matches(null, "any"), "any sollte alles erkennen")
	check(not registry.type_matches(1, "string"), "number sollte nicht als string gelten")


func test_verzeichnis() -> void:
	registry.register(
		"a.first",
		"Erstes Element.",
		{"x": "string"},
		Callable(self, "_dummy_handler")
	)

	var caps: Array[Dictionary] = registry.capabilities() as Array[Dictionary]
	check(caps.size() == 2, "Es sollten zwei Einträge im Verzeichnis sein")

	var names: Array[String] = []
	for cap in caps:
		names.append(cap["name"])

	check(names[0] == "a.first", "Erster Befehl im sortierten Verzeichnis")
	check(names[1] == "math.add", "Zweiter Befehl im sortierten Verzeichnis")

	var math_cap: Dictionary = {}
	for cap in caps:
		if cap["name"] == "math.add":
			math_cap = cap
			break

	check(not math_cap.is_empty(), "math.add sollte im Verzeichnis sein")
	check(not math_cap.has("handler"), "Verzeichnis soll keinen handler haben")
	check_eq(math_cap["params"], {"a": "number", "b": "number"}, "params sollen korrekt sein")


func _dummy_handler(_args: Dictionary) -> CommandResult:
	return CommandResult.success({})
