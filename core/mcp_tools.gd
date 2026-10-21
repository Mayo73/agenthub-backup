class_name McpTools
extends RefCounted
## Wandelt CommandRegistry-Befehle in MCP-Werkzeuge um und führt sie aus.
## Nur statische Funktionen, keine Instanzen nötig.


static func json_type(type_name: String) -> String:
	## Konvertiert CommandRegistry-Typen in JSON-Schema-Typen.
	match type_name:
		"string":
			return "string"
		"number":
			return "number"
		"bool":
			return "boolean"
		"dict":
			return "object"
		"array":
			return "array"
		_:
			return ""


static func tool_name(command: String) -> String:
	## Wandelt Befehlsnamen in MCP-gerechte Tool-Namen um.
	## Punkte werden durch __ ersetzt (MCP erlaubt keine Punkte).
	return command.replace(".", "__")


static func command_name(tool: String) -> String:
	## Wandelt MCP-Tool-Namen zurück in Befehlsnamen.
	## __ wird zu Punkten ersetzt.
	return tool.replace("__", ".")


static func tools(registry: CommandRegistry) -> Array[Dictionary]:
	## Erstellt MCP-Tool-Beschreibungen aus allen registrierten Befehlen.
	var result: Array[Dictionary] = []

	for cap in registry.capabilities():
		var name: String = tool_name(cap["name"])
		var description: String = cap["description"]
		var params: Dictionary = cap["params"]

		# properties aus Parametern bauen
		var properties: Dictionary = {}
		var required: Array[String] = []
		var sorted_names: Array[String] = []

		for param_name in params.keys():
			sorted_names.append(param_name)

		sorted_names.sort_custom(func(a: String, b: String): return a < b)

		for param_name in sorted_names:
			var type_str: String = params[param_name]
			var prop: Dictionary = {}
			if not type_str.is_empty():
				prop["type"] = json_type(type_str)
			properties[param_name] = prop
			required.append(param_name)

		var tool: Dictionary = {
			"name": name,
			"description": description,
			"inputSchema": {
				"type": "object",
				"properties": properties,
				"required": required
			}
		}
		result.append(tool)

	return result


static func call_tool(registry: CommandRegistry, params: Dictionary) -> Dictionary:
	## Führt ein MCP-Tool aus und liefert MCP-kompatibles Ergebnis.
	var name: String = params["name"] as String
	var arguments: Dictionary = params.get("arguments", {})

	var command: String = command_name(name)
	var ergebnis: CommandResult = registry.execute(command, arguments)

	var result: Dictionary = {
		"content": [{"type": "text", "text": JSON.stringify(ergebnis.to_dict())}],
		"isError": not ergebnis.is_ok()
	}

	return result
