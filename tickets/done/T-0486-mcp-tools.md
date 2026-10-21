---
id: T-0486
title: McpTools – Befehlsverzeichnis als MCP-Werkzeuge anbieten
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „KI, Agenten und Hub“ (Muss 7: jede veröffentlichte Projektfunktion ohne Klickautomation aufrufbar, MCP-Adapter): Die Befehle aus `CommandRegistry` werden als MCP-Werkzeuge beschrieben und aufgerufen.

## Dateien
- `core/mcp_tools.gd` – neu, Klasse `McpTools`
- `tests/test_mcp_tools.gd` – neu

## Akzeptanzkriterien
`class_name McpTools`, `extends RefCounted`, nur statische Funktionen. Vorher `core/command_registry.gd` lesen (`capabilities()` liefert je Befehl `"name"`, `"description"`, `"params"`; `params` ordnet Parameternamen einen Typ aus `CommandRegistry.TYPES` zu).
- `static func json_type(type_name: String) -> String`: `"string"` → `"string"`, `"number"` → `"number"`, `"bool"` → `"boolean"`, `"dict"` → `"object"`, `"array"` → `"array"`, sonst `""` (beliebig)
- `static func tool_name(command: String) -> String`: Punkte durch `__` ersetzt (MCP erlaubt keine Punkte), z. B. `scene.add` → `scene__add`; `static func command_name(tool: String) -> String` macht das rückgängig
- `static func tools(registry: CommandRegistry) -> Array[Dictionary]`: je Befehl `{"name": tool_name(...), "description": ..., "inputSchema": {"type": "object", "properties": {param: {"type": json_type}} (bei leerem Typ nur {}), "required": alle Parameternamen sortiert}}`
- `static func call_tool(registry: CommandRegistry, params: Dictionary) -> Dictionary`: liest `params["name"]` und `params.get("arguments", {})`, führt `registry.execute(command_name(name), arguments)` aus und liefert `{"content": [{"type": "text", "text": JSON.stringify(ergebnis.to_dict())}], "isError": not ergebnis.is_ok()}`

## Tests
`tests/test_mcp_tools.gd`, `setup()`: `registry = CommandRegistry.new()`, `model = SceneModel.new()`, `SceneCommands.register_all(registry, model)` (wie in `tests/test_command_plan.gd`):
- `test_typen`: `json_type("bool")` „boolean“, `json_type("dict")` „object“, `json_type("any")` „“
- `test_namen`: `tool_name("scene.add")` „scene__add“, `command_name("scene__add")` „scene.add“
- `test_liste`: `tools(registry)` hat so viele Einträge wie `registry.capabilities()`; der Eintrag „scene__add“ hat `inputSchema.type` „object“ und `"type"` in `required`
- `test_aufruf`: `call_tool(registry, {"name": "scene__add", "arguments": {"type": "Node2D", "parent": "", "props": {}}})` → `isError` falsch, `model.order.size()` 1
- `test_fehler`: `call_tool(registry, {"name": "zaubern", "arguments": {}})` → `isError` wahr

Review (21.10.2026): gemergt, nachgebessert: Parameter mit beliebigem Typ bekommen ein leeres Schema statt {"type": ""}.
