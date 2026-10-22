---
id: T-0604
title: ChatHistory – Gesprächsverlauf für den Assistenten
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „KI, Agenten und Hub“: Den Verlauf zwischen Nutzer und Assistent führen und als Textliste ausgeben, deren erster Eintrag die Systemanweisung ist (passt zu `TokenBudget.trim`).

## Dateien
- `core/chat_history.gd` – neu, Klasse `ChatHistory`
- `tests/test_chat_history.gd` – neu

## Akzeptanzkriterien
`class_name ChatHistory`, `extends RefCounted`.
- `const ROLES := ["user", "assistant"]`
- `var system_text := ""`, `var messages: Array[Dictionary] = []` (je `{"role": String, "text": String}`)
- `func _init(system: String = "") -> void`
- `func add(role: String, text: String) -> bool`: Rolle nicht in `ROLES` oder `text.strip_edges()` leer → `false`; sonst mit `strip_edges()` anhängen, `true`
- `func last(n: int) -> Array[Dictionary]`: die letzten `n` Nachrichten in ihrer Reihenfolge; `n <= 0` → `[]`
- `func as_texts() -> Array[String]`: zuerst `system_text` (nur wenn nicht leer), dann je Nachricht `"Nutzer: …"` bzw. `"Assistent: …"`
- `func clear() -> void`: nur `messages` leeren, `system_text` bleibt

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs. Werte aus Dictionaries mit Typ lesen (`var t: String = m["text"]`).

## Tests
`tests/test_chat_history.gd`, jeweils `ChatHistory.new("Du baust Szenen.")`:
- `test_hinzufuegen`: `add("user", "Hallo")` wahr; `add("system", "x")` falsch; `add("assistant", "  ")` falsch; `messages.size()` 1
- `test_letzte`: `add("user", "Hallo")`, `add("assistant", " Hi ")` → `last(1)[0]["text"]` „Hi“, `last(5).size()` 2, `last(0)` leer
- `test_texte`: nach denselben Nachrichten ist `as_texts()` gleich `["Du baust Szenen.", "Nutzer: Hallo", "Assistent: Hi"]`; `ChatHistory.new().as_texts()` ist leer
- `test_leeren`: nach `clear()` ist `messages` leer und `as_texts().size()` 1
