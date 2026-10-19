class_name CommandRegistry
extends RefCounted
## Verwaltet Befehle für GUI, CLI und Agenten mit Parameterprüfung.

const TYPES: Array[String] = ["string", "number", "bool", "dict", "array", "any"]

var commands: Dictionary = {}  # Name -> {"name", "description", "params", "handler"}


func register(name: String, description: String, params: Dictionary, handler: Callable) -> void:
	## Befehl registrieren. Alle Parameter sind Pflicht.
	var cmd: Dictionary = {
		"name": name,
		"description": description,
		"params": params,
		"handler": handler
	}
	commands[name] = cmd


func has_command(name: String) -> bool:
	return name in commands


func type_matches(value: Variant, type_name: String) -> bool:
	## Prüft, ob ein Wert einem Typ entspricht.
	if type_name == "any":
		return true

	match type_name:
		"string":
			return typeof(value) == TYPE_STRING
		"number":
			return typeof(value) in [TYPE_INT, TYPE_FLOAT]
		"bool":
			return typeof(value) == TYPE_BOOL
		"dict":
			return typeof(value) == TYPE_DICTIONARY
		"array":
			return typeof(value) == TYPE_ARRAY
		_:
			return false

	return false


func execute(name: String, args: Dictionary) -> CommandResult:
	## Befehl ausführen und Parameter prüfen.
	if not has_command(name):
		return CommandResult.error(CommandResult.UNKNOWN_COMMAND, "Unbekannter Befehl: %s" % name)

	var cmd: Dictionary = commands[name]
	var params: Dictionary = cmd.params

	# Prüfe, ob alle Parameter vorhanden sind
	for param_name in params:
		if not param_name in args:
			return CommandResult.error(
				CommandResult.INVALID_ARGUMENT,
				"Parameter fehlt: %s" % param_name
			)

	# Prüfe Typen der Parameter
	for param_name in params:
		var expected_type: String = params[param_name]
		var value: Variant = args[param_name]
		if not type_matches(value, expected_type):
			return CommandResult.error(
				CommandResult.INVALID_ARGUMENT,
				"Parameter %s muss %s sein" % [param_name, expected_type]
			)

	# Alle Prüfungen bestanden – Handler aufrufen
	return cmd.handler.call(args)


func capabilities() -> Array[Dictionary]:
	## Verzeichnis aller Befehle ohne Handler, nach Name sortiert.
	var result: Array[Dictionary] = []

	for name in commands.keys():
		var cmd: Dictionary = commands[name]
		var cap: Dictionary = {
			"name": cmd["name"],
			"description": cmd["description"],
			"params": cmd["params"]
		}
		result.append(cap)

	result.sort_custom(func(a: Dictionary, b: Dictionary): return a["name"] < b["name"])
	return result
