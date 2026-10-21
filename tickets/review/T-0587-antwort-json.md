---
id: T-0587
title: ResponseParser – JSON aus KI-Antworten lesen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „KI, Agenten und Hub“: Aus der Textantwort eines Modells den JSON-Befehlsblock herauslösen und Fehler verständlich melden.

## Dateien
- `core/response_parser.gd` – neu, Klasse `ResponseParser`
- `tests/test_response_parser.gd` – neu

## Akzeptanzkriterien
`class_name ResponseParser`, `extends RefCounted`, nur statische Funktionen.
- `static func extract_json(text: String) -> Dictionary`: Ergebnis `{"ok": bool, "data": Variant, "error": String}`
  1. Kommt `"```json"` vor: den Text danach bis zum nächsten `"```"` nehmen (fehlt das Ende: bis zum Textende)
  2. sonst vom ersten `"{"` bis zum letzten `"}"` (beide eingeschlossen); fehlt eins davon → `{"ok": false, "data": null, "error": "kein_json"}`
  3. `var json := JSON.new()`, `json.parse(teil.strip_edges())`; Ergebnis nicht `OK` → Fehler `"ungueltig"`
  4. `json.data` ist kein Dictionary → Fehler `"kein_objekt"`; sonst `{"ok": true, "data": json.data, "error": ""}`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq` (Zahlen vergleicht `check_eq` ungefähr). Einrückung nur mit Tabs. Die drei Backticks im Code als `"```"` schreiben.

## Tests
`tests/test_response_parser.gd`:
- `test_block`: `"Hier:\n```json\n{\"a\": 1}\n```\nFertig"` → `ok` wahr, `data["a"]` ist 1
- `test_klammern`: `"Antwort {\"b\": [1, 2]} Ende"` → `ok` wahr, `data["b"].size()` ist 2
- `test_kein_json`: `"nur Text"` → `ok` falsch, `error` ist `"kein_json"`
- `test_ungueltig`: `"{kaputt}"` → `error` ist `"ungueltig"`
- `test_kein_objekt`: `"```json\n[1, 2]\n```"` → `error` ist `"kein_objekt"`
