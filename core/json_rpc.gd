class_name JsonRpc
extends RefCounted

## Statikus JSON-RPC 2.0 Parser und Builder
## Keine Netzwerkfunktionen, rein logisch


# Fehlercodes nach JSON-RPC 2.0 Specification
const PARSE_ERROR := -32700
const INVALID_REQUEST := -32600
const METHOD_NOT_FOUND := -32601
const INVALID_PARAMS := -32602
const INTERNAL_ERROR := -32603


## Parse eine JSON-RPC 2.0 Nachricht
## @param text: Der JSON-String
## @return Dictionary mit „ok" (bool), bei Erfolg auch „id", „method", „params", „notification"
static func parse(text: String) -> Dictionary:
	var result: Dictionary = { "ok": false, "error": PARSE_ERROR, "id": null }

	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		return result

	var parsed: Variant = json.data
	if parsed == null:
		return result

	if not typeof(parsed) == TYPE_DICTIONARY:
		result["error"] = INVALID_REQUEST
		return result

	var jsonrpc_dict: Dictionary = parsed as Dictionary

	# id bereits speichern für INVALID_REQUEST-Fälle
	var id: Variant = jsonrpc_dict.get("id")

	if jsonrpc_dict.get("jsonrpc") != "2.0":
		result["error"] = INVALID_REQUEST
		result["id"] = id
		return result

	if not jsonrpc_dict.has("method") or typeof(jsonrpc_dict.get("method")) != TYPE_STRING:
		result["error"] = INVALID_REQUEST
		result["id"] = id
		return result

	var method: String = jsonrpc_dict.get("method") as String
	var params: Dictionary = jsonrpc_dict.get("params", {}) as Dictionary
	var has_id: bool = jsonrpc_dict.has("id")

	if not typeof(params) == TYPE_DICTIONARY:
		params = {}

	result["ok"] = true
	result["id"] = id
	result["method"] = method
	result["params"] = params
	result["notification"] = not has_id

	return result


## Baut eine Ergebnis-Nachricht JSON-RPC 2.0
## @param id: Die Message-ID (kann null sein)
## @param value: Das Ergebnis
## @return JSON-String
static func result(id: Variant, value: Variant) -> String:
	return JSON.stringify({ "jsonrpc": "2.0", "id": id, "result": value })


## Baut eine Fehler-Nachricht JSON-RPC 2.0
## @param id: Die Message-ID (kann null sein)
## @param code: Der Fehlercode
## @param message: Eine fehlerbeschreibung als String
## @return JSON-String
static func error(id: Variant, code: int, message: String) -> String:
	return JSON.stringify({ "jsonrpc": "2.0", "id": id, "error": { "code": code, "message": message } })
