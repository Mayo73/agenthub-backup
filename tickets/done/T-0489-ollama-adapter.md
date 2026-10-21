---
id: T-0489
title: OllamaAdapter – Anfrage bauen und Antwort lesen (ohne Netzwerk)
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „KI, Agenten und Hub“ (Muss 9: austauschbare Provideradapter, vorhandene lokale Modelle nutzen): Der Adapter für Ollama baut die Anfrage für `/api/chat` und liest die Antwort. Das eigentliche Senden übernimmt später ein Laufzeitteil; der Kern bleibt ohne Netzwerk testbar.

## Dateien
- `core/ollama_adapter.gd` – neu, Klasse `OllamaAdapter`
- `tests/test_ollama_adapter.gd` – neu

## Akzeptanzkriterien
`class_name OllamaAdapter`, `extends RefCounted`, nur statische Funktionen.
- `const DEFAULT_URL := "http://localhost:11434"`, `const CHAT_PATH := "/api/chat"`
- `static func chat_url(base: String = DEFAULT_URL) -> String`: `base` ohne abschließenden `/` plus `CHAT_PATH`
- `static func build_request(model: String, system: String, prompt: String) -> Dictionary`: `{"model": model, "stream": false, "messages": [...]}`; `messages` enthält `{"role": "system", "content": system}` nur bei nicht leerem `system`, danach immer `{"role": "user", "content": prompt}`
- `static func parse_response(text: String) -> CommandResult`: Kein gültiges JSON-Dictionary → `CommandResult.error(CommandResult.EXEC_FAILED, "Antwort des Modells ist kein JSON")`. Hat es `"error"` → `EXEC_FAILED` mit `"Ollama: " + str(error)`. Sonst muss `message.content` ein String sein → `success({"text": content, "model": str(d.get("model", ""))})`, sonst `EXEC_FAILED`, `"Antwort ohne Text"`.

## Tests
`tests/test_ollama_adapter.gd`:
- `test_url`: `chat_url("http://pc:11434/")` ist „http://pc:11434/api/chat“, `chat_url()` endet auf „/api/chat“
- `test_anfrage`: `build_request("qwen3.5:9b", "Du hilfst.", "Hallo")` → `messages.size()` 2, `messages[0].role` „system“, `stream` falsch; ohne System-Text → `messages.size()` 1
- `test_antwort`: `parse_response('{"model": "qwen3.5:9b", "message": {"role": "assistant", "content": "Hi"}}')` ok, `data.text` „Hi“
- `test_fehler`: `parse_response('{"error": "model not found"}')` → Code `CommandResult.EXEC_FAILED`, Meldung enthält „model not found“
- `test_kaputt`: `parse_response("<html>")` → nicht ok

Review (21.10.2026): gemergt, nachgebessert: parse_response verträgt Zeilenumbruch am Ende, kaputtes JSON und Inhalt ohne Text führen zu EXEC_FAILED statt Laufzeitfehler.
