class_name McpServer
extends RefCounted
## Antwortet auf MCP-Nachrichten (initialize, tools/list, tools/call, ping).
## Wird über stdio verwendet; hier nur die Logik ohne I/O.


const PROTOCOL_VERSION := "2025-06-18"
const SERVER_NAME := "hub-engine"


var registry: CommandRegistry


func _init(r: CommandRegistry) -> void:
	registry = r


func handle(line: String) -> String:
	var parsed := JsonRpc.parse(line)
	if not parsed.ok:
		return JsonRpc.error(parsed.id, parsed.error, "Ungültige Nachricht")

	if parsed.notification:
		return ""

	match parsed.method:
		"initialize":
			return _make_initialize_response(parsed.id)
		"tools/list":
			return _make_tools_list_response(parsed.id)
		"tools/call":
			return _make_tools_call_response(parsed.id, parsed.params)
		"ping":
			return JsonRpc.result(parsed.id, {})
		_:
			return JsonRpc.error(parsed.id, JsonRpc.METHOD_NOT_FOUND, "Methode %s gibt es nicht" % parsed.method)

	return ""


func _make_initialize_response(id: Variant) -> String:
	var data: Dictionary = {
		"protocolVersion": PROTOCOL_VERSION,
		"capabilities": {"tools": {}},
		"serverInfo": {
			"name": SERVER_NAME,
			"version": "0.1"
		}
	}
	return JsonRpc.result(id, data)


func _make_tools_list_response(id: Variant) -> String:
	var tools := McpTools.tools(registry)
	return JsonRpc.result(id, {"tools": tools})


func _make_tools_call_response(id: Variant, params: Dictionary) -> String:
	var name: Variant = params.get("name", null)
	if name == null:
		return JsonRpc.error(id, JsonRpc.INVALID_PARAMS, "Werkzeugname fehlt")

	var result := McpTools.call_tool(registry, params)
	return JsonRpc.result(id, result)
