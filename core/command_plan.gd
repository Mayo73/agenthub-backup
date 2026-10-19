class_name CommandPlan
extends RefCounted
## Befehlsfolgen aus KI-Antworten lesen, prüfen und ausführen.

static func extract_json(text: String) -> String:
	## Sucht einen Code-Block zwischen drei Backticks (optional mit `json`),
	## sonst den Text ab dem ersten `[` bis zum letzten `]`.
	var regex := RegEx.new()
	regex.compile("\\n?```(?:json)?\\n?([\\s\\S]*?)\\n?```")

	var match := regex.search(text)
	if match != null:
		return match.get_string(1).strip_edges()

	var start := text.find("[")
	if start >= 0:
		var end := text.rfind("]")
		if end >= start:
			return text.substr(start, end - start + 1)

	return ""


static func parse(text: String) -> CommandResult:
	## Extrahiert JSON-Block, parst Array von Befehls-Schritten.
	var json_text := extract_json(text)
	if json_text.is_empty():
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Antwort enthält keinen gültigen Befehlsplan")

	var result: Variant = JSON.parse_string(json_text)
	if typeof(result) != TYPE_ARRAY:
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Antwort enthält keinen gültigen Befehlsplan")

	var steps: Array[Dictionary] = []
	for item in result:
		if typeof(item) != TYPE_DICTIONARY:
			return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Antwort enthält keinen gültigen Befehlsplan")

		if not "command" in item or typeof(item["command"]) != TYPE_STRING:
			return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Antwort enthält keinen gültigen Befehlsplan")

		var cmd_name := item["command"] as String
		var args: Dictionary = {}
		if "args" in item and typeof(item["args"]) == TYPE_DICTIONARY:
			args = item["args"]

		steps.append({"command": cmd_name, "args": args})

	return CommandResult.success({"steps": steps})


static func check(registry: CommandRegistry, steps: Array[Dictionary]) -> Array[String]:
	## Prüft jeden Schritt gegen das Befehlsverzeichnis, zurück Liste der Fehler.
	var problems: Array[String] = []

	for i in steps.size():
		var step: Dictionary = steps[i]
		if not "command" in step or typeof(step["command"]) != TYPE_STRING:
			problems.append("Schritt %d: Befehl fehlt" % (i + 1))
			continue

		var cmd_name := step["command"] as String
		if not registry.has_command(cmd_name):
			problems.append("Schritt %d: Befehl %s gibt es nicht" % [i + 1, cmd_name])

	return problems


static func run(registry: CommandRegistry, steps: Array[Dictionary]) -> CommandResult:
	## Führt die Schritte nacheinander aus, abbrich beim ersten Fehler.
	var problems := check(registry, steps)
	if not problems.is_empty():
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "; ".join(problems))

	var results: Array[Variant] = []

	for i in steps.size():
		var step: Dictionary = steps[i]
		var cmd_name := step["command"] as String
		var args: Dictionary = step.get("args", {})

		var ergebnis := registry.execute(cmd_name, args)
		if not ergebnis.is_ok():
			return CommandResult.error(
				ergebnis.code,
				"Schritt %d: %s" % [i + 1, ergebnis.message],
				{"done": i}
			)

		results.append(ergebnis.data)

	return CommandResult.success({"done": steps.size(), "results": results})
