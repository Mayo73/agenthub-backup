extends "res://tests/base_test.gd"

var registry: CommandRegistry
var model: SceneModel


func setup() -> void:
	registry = CommandRegistry.new()
	model = SceneModel.new()
	SceneCommands.register_all(registry, model)


func test_typen() -> void:
	check_eq(McpTools.json_type("bool"), "boolean", "bool → boolean")
	check_eq(McpTools.json_type("dict"), "object", "dict → object")
	check_eq(McpTools.json_type("any"), "", "any → leerer String")


func test_namen() -> void:
	check_eq(McpTools.tool_name("scene.add"), "scene__add", "Punkte zu __")
	check_eq(McpTools.command_name("scene__add"), "scene.add", "__ zurück zu Punkten")


func test_liste() -> void:
	var tool_list: Array[Dictionary] = McpTools.tools(registry)
	var caps: Array[Dictionary] = registry.capabilities()

	check_eq(tool_list.size(), caps.size(), "gleiche Anzahl Einträge")

	var add_tool: Dictionary = {}
	for tool in tool_list:
		if tool["name"] == "scene__add":
			add_tool = tool
			break

	check(not add_tool.is_empty(), "scene__add gefunden")
	check_eq(add_tool["inputSchema"]["type"], "object", "inputSchema.type ist object")
	check("type" in add_tool["inputSchema"]["required"], "\"type\" in required")


func test_aufruf() -> void:
	var params: Dictionary = {
		"name": "scene__add",
		"arguments": {"type": "Node2D", "parent": "", "props": {}}
	}

	var result: Dictionary = McpTools.call_tool(registry, params)

	check(not result["isError"], "isError sollte falsch sein")
	check_eq(result.size(), 2, "zwei Felder in Ergebnis")
	var ergebnis_dict: Dictionary = JSON.parse_string(result["content"][0]["text"]) as Dictionary
	check(ergebnis_dict.get("ok", false), "CommandResult ist ok")
	check_eq(model.order.size(), 1, "ein Objekt hinzugefügt")


func test_fehler() -> void:
	var params: Dictionary = {
		"name": "zaubern",
		"arguments": {}
	}

	var result: Dictionary = McpTools.call_tool(registry, params)

	check(result["isError"], "isError sollte wahr sein für unbekannten Befehl")
	var ergebnis_dict: Dictionary = JSON.parse_string(result["content"][0]["text"]) as Dictionary
	check(not ergebnis_dict.get("ok", true), "CommandResult ist error")
