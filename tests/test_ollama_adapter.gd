extends "res://tests/base_test.gd"


func test_url() -> void:
	var url1: String = OllamaAdapter.chat_url("http://pc:11434/")
	check(url1 == "http://pc:11434/api/chat", "chat_url mit trailing slash")

	var url2: String = OllamaAdapter.chat_url()
	check(url2.ends_with("/api/chat"), "chat_url() endet auf /api/chat")


func test_anfrage() -> void:
	var req := OllamaAdapter.build_request("qwen3.5:9b", "Du hilfst.", "Hallo")
	var messages: Array[Dictionary] = req.get("messages", [])

	check(messages.size() == 2, "messages.size() 2 bei System-Text")
	check(messages[0].get("role") == "system", "messages[0].role system")

	req = OllamaAdapter.build_request("qwen3.5:9b", "", "Hallo")
	messages = req.get("messages", [])
	check(messages.size() == 1, "messages.size() 1 ohne System-Text")

	check(req.get("stream") == false, "stream falsch")


func test_antwort() -> void:
	var text := '{"model": "qwen3.5:9b", "message": {"role": "assistant", "content": "Hi"}}'
	var result := OllamaAdapter.parse_response(text)

	check(result.is_ok(), "Antwort ok")
	var data: Dictionary = result.data
	check(data.get("text") == "Hi", "data.text Hi")
	check(data.get("model") == "qwen3.5:9b", "data.model qwen3.5:9b")


func test_fehler() -> void:
	var text := '{"error": "model not found"}'
	var result := OllamaAdapter.parse_response(text)

	check(result.code == CommandResult.EXEC_FAILED, "Code EXEC_FAILED")
	check(result.message.contains("model not found"), "Meldung enthält Fehler")


func test_zeilenumbruch_und_ohne_text() -> void:
	var result := OllamaAdapter.parse_response('{"message": {"content": "Hi"}}\n')
	check(result.is_ok(), "Zeilenumbruch am Ende stört nicht")
	result = OllamaAdapter.parse_response('{"message": {"content": 5}}')
	check(not result.is_ok(), "Inhalt ohne Text ist ein Fehler")
	result = OllamaAdapter.parse_response('{kaputt}')
	check(not result.is_ok(), "kaputtes JSON in Klammern ist ein Fehler")


func test_kaputt() -> void:
	var text := "<html>"
	var result := OllamaAdapter.parse_response(text)
	check(not result.is_ok(), "kaputtes JSON nicht ok")
