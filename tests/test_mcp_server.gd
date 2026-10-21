extends "res://tests/base_test.gd"

var registry: CommandRegistry
var model: SceneModel
var server: McpServer


func setup() -> void:
	registry = CommandRegistry.new()
	model = SceneModel.new()
	SceneCommands.register_all(registry, model)
	server = McpServer.new(registry)


func test_initialize() -> void:
	var request := '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}'
	var response := server.handle(request) as String

	var parsed: Dictionary = JSON.parse_string(response)
	check(parsed.result.serverInfo.name == "hub-engine", "serverInfo.name ist hub-engine")


func test_liste() -> void:
	var request := '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'
	var response := server.handle(request) as String

	var parsed: Dictionary = JSON.parse_string(response)
	var tool_list: Array = parsed.result.tools as Array
	var caps: Array = registry.capabilities()

	check_eq(tool_list.size(), caps.size(), "tools.size() gleich capabilities.size()")


func test_aufruf() -> void:
	var request := '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"scene__add","arguments":{"type":"Node2D","parent":"","props":{}}}}'
	var response := server.handle(request) as String

	var parsed: Dictionary = JSON.parse_string(response)
	check(not parsed.result.isError, "isError sollte falsch sein")
	check_eq(model.order.size(), 1, "model.order.size() ist 1")


func test_benachrichtigung() -> void:
	var notification := '{"jsonrpc":"2.0","method":"notifications/initialized"}'
	var response := server.handle(notification) as String

	check(response.is_empty(), "Benachrichtigung gibt leere Antwort zurück")


func test_unbekannt() -> void:
	var request := '{"jsonrpc":"2.0","id":5,"method":"zaubern","params":{}}'
	var response := server.handle(request) as String

	var parsed: Dictionary = JSON.parse_string(response)
	check_eq(int(parsed.error.code), -32601, "error.code ist -32601 (METHOD_NOT_FOUND)")
