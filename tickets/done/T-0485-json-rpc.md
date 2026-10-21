---
id: T-0485
title: JsonRpc – Nachrichten nach JSON-RPC 2.0 lesen und schreiben
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „KI, Agenten und Hub“ (Muss 7: MCP-Adapter für ChatGPT und Claude): MCP spricht JSON-RPC 2.0. Diese Klasse liest eingehende Nachrichten und baut Antworten, ohne Netzwerk.

## Dateien
- `core/json_rpc.gd` – neu, Klasse `JsonRpc`
- `tests/test_json_rpc.gd` – neu

## Akzeptanzkriterien
`class_name JsonRpc`, `extends RefCounted`, nur statische Funktionen.
- Fehlercodes als Konstanten: `const PARSE_ERROR := -32700`, `const INVALID_REQUEST := -32600`, `const METHOD_NOT_FOUND := -32601`, `const INVALID_PARAMS := -32602`, `const INTERNAL_ERROR := -32603`
- `static func parse(text: String) -> Dictionary`: Ergebnis immer ein Dictionary mit `"ok"` (bool). Kein gültiges JSON → `{"ok": false, "error": PARSE_ERROR, "id": null}`. JSON, aber kein Dictionary, oder `"jsonrpc"` ist nicht `"2.0"`, oder `"method"` fehlt bzw. ist kein String → `{"ok": false, "error": INVALID_REQUEST, "id": <id aus der Nachricht oder null>}`. Sonst `{"ok": true, "id": <id oder null>, "method": String, "params": <params als Dictionary, Standard {}>, "notification": <true, wenn die Nachricht keinen Schlüssel "id" hat>}`
- `static func result(id: Variant, value: Variant) -> String`: `JSON.stringify({"jsonrpc": "2.0", "id": id, "result": value})`
- `static func error(id: Variant, code: int, message: String) -> String`: `JSON.stringify({"jsonrpc": "2.0", "id": id, "error": {"code": code, "message": message}})`

## Tests
`tests/test_json_rpc.gd`:
- `test_anfrage`: `parse('{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}')` → `ok` wahr, `method` „tools/list“, `params` leer, `notification` falsch, `int(id)` 1
- `test_benachrichtigung`: ohne `"id"` → `notification` wahr
- `test_kaputt`: `parse("{kaputt")` → `ok` falsch, `error` `JsonRpc.PARSE_ERROR`
- `test_falsche_version`: `"jsonrpc": "1.0"` mit `"id": 7` → `error` `JsonRpc.INVALID_REQUEST`, `int(id)` 7
- `test_antwort`: `JSON.parse_string(JsonRpc.result(3, {"a": 1}))` hat `"jsonrpc"` „2.0“, `int(["id"])` 3 und `result.a` 1
- `test_fehler`: `JSON.parse_string(JsonRpc.error(4, JsonRpc.METHOD_NOT_FOUND, "Unbekannt"))` hat `int(error.code)` -32601 und `error.message` „Unbekannt“

Review (21.10.2026): gemergt, nachgebessert: params als Liste ergibt {} statt eines Cast-Fehlers (neuer Test).
