class_name OllamaAdapter
extends RefCounted
## Adapter für Ollama API (lokale Modelle), ohne Netzwerk-Zugriffe.

const DEFAULT_URL := "http://localhost:11434"
const CHAT_PATH := "/api/chat"


static func chat_url(base: String = DEFAULT_URL) -> String:
	var clean_base: String = base.rstrip("/")
	return clean_base + CHAT_PATH


static func build_request(model: String, system: String, prompt: String) -> Dictionary:
	var messages: Array[Dictionary] = []

	if not system.is_empty():
		messages.append({"role": "system", "content": system})

	messages.append({"role": "user", "content": prompt})

	return {
		"model": model,
		"stream": false,
		"messages": messages
	}


static func parse_response(text: String) -> CommandResult:
	if not text.begins_with("{") or not text.ends_with("}"):
		return CommandResult.error(CommandResult.EXEC_FAILED, "Antwort des Modells ist kein JSON")

	var dict: Dictionary = JSON.parse_string(text)
	if typeof(dict) != TYPE_DICTIONARY:
		return CommandResult.error(CommandResult.EXEC_FAILED, "Antwort des Modells ist kein JSON")

	if dict.has("error"):
		return CommandResult.error(CommandResult.EXEC_FAILED, "Ollama: " + str(dict["error"]))

	var message: Dictionary = dict.get("message", {})
	if typeof(message) != TYPE_DICTIONARY:
		return CommandResult.error(CommandResult.EXEC_FAILED, "Antwort ohne Text")

	var content: String = message.get("content", "")
	if typeof(content) != TYPE_STRING:
		return CommandResult.error(CommandResult.EXEC_FAILED, "Antwort ohne Text")

	return CommandResult.success(
		{"text": content, "model": str(dict.get("model", ""))},
		content
	)
