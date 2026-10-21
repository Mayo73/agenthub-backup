---
id: T-0487
title: McpServer – MCP-Anfragen beantworten (initialize, tools/list, tools/call)
project: hub-engine
priority: 4
after: T-0485, T-0486
---
## Ziel
Meilenstein „KI, Agenten und Hub“ (Muss 7, Abnahmekriterium Agentenverbindung): Eine Klasse beantwortet MCP-Nachrichten Zeile für Zeile (wie bei MCP über stdio). Der eigentliche Prozess mit stdin/stdout kommt später; hier nur die Logik.

## Dateien
- `core/mcp_server.gd` – neu, Klasse `McpServer`
- `tests/test_mcp_server.gd` – neu

## Akzeptanzkriterien
`class_name McpServer`, `extends RefCounted`. Vorher `core/json_rpc.gd` und `core/mcp_tools.gd` lesen.
- `const PROTOCOL_VERSION := "2025-06-18"`, `const SERVER_NAME := "hub-engine"`
- `var registry: CommandRegistry`; `func _init(r: CommandRegistry) -> void`
- `func handle(line: String) -> String`: `JsonRpc.parse(line)`; ungültig → `JsonRpc.error(id, error, "Ungültige Nachricht")`. Benachrichtigungen (`notification` wahr) → `""` (keine Antwort). Sonst nach `method`:
  - `"initialize"` → `JsonRpc.result(id, {"protocolVersion": PROTOCOL_VERSION, "capabilities": {"tools": {}}, "serverInfo": {"name": SERVER_NAME, "version": "0.1"}})`
  - `"tools/list"` → `JsonRpc.result(id, {"tools": McpTools.tools(registry)})`
  - `"tools/call"` → fehlt `params["name"]`: `JsonRpc.error(id, JsonRpc.INVALID_PARAMS, "Werkzeugname fehlt")`; sonst `JsonRpc.result(id, McpTools.call_tool(registry, params))`
  - `"ping"` → `JsonRpc.result(id, {})`
  - sonst `JsonRpc.error(id, JsonRpc.METHOD_NOT_FOUND, "Methode %s gibt es nicht" % method)`

## Tests
`tests/test_mcp_server.gd`, `setup()`: Registry mit `SceneCommands.register_all(registry, model)`, `server = McpServer.new(registry)`:
- `test_initialize`: Antwort auf `{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}` hat `result.serverInfo.name` „hub-engine“
- `test_liste`: `tools/list` → `result.tools.size()` gleich `registry.capabilities().size()`
- `test_aufruf`: `tools/call` mit `{"name": "scene__add", "arguments": {"type": "Node2D", "parent": "", "props": {}}}` → `result.isError` falsch, `model.order.size()` 1
- `test_benachrichtigung`: `{"jsonrpc":"2.0","method":"notifications/initialized"}` → `""`
- `test_unbekannt`: Methode „zaubern“ mit id 5 → `int(error.code)` -32601

Review (21.10.2026): gemergt.
