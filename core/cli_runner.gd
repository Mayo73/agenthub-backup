class_name CliRunner
extends RefCounted

## Führt Befehle über die CLI aus und gibt Ergebnisse als JSON zurück.
## Nutzt CommandRegistry für die Ausführung und CliParser zum Parsen der Argumente.

const EXIT_OK := 0
const EXIT_ERROR := 1
const EXIT_USAGE := 2

var registry: CommandRegistry


func _init(reg: CommandRegistry) -> void:
	registry = reg


static func result_to_dict(r: CommandResult) -> Dictionary:
	return {"ok": r.code == CommandResult.CODE_OK, "code": r.code, "message": r.message, "data": r.data}


func run(argv: PackedStringArray) -> Dictionary:
	var parsed: Dictionary = CliParser.parse(argv)

	# Parser-Fehler → Usage Error
	if not parsed["error"].is_empty():
		return {
			"exit_code": EXIT_USAGE,
			"output": JSON.stringify({"ok": false, "code": "invalid_argument", "message": parsed["error"], "data": {}})
		}

	var command: String = parsed["command"]
	var args: Dictionary = parsed["args"]

	# Special case: help command
	if command == "help":
		var capabilities: Array[Dictionary] = registry.capabilities()
		return {
			"exit_code": EXIT_OK,
			"output": JSON.stringify({"ok": true, "code": "ok", "message": "", "data": {"commands": capabilities}})
		}

	# Execute command via registry
	var result: CommandResult = registry.execute(command, args)
	var output_dict := result_to_dict(result)

	return {
		"exit_code": EXIT_OK if result.is_ok() else EXIT_ERROR,
		"output": JSON.stringify(output_dict)
	}
