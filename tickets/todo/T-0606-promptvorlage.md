---
id: T-0606
title: PromptTemplate – Platzhalter in Auftragsvorlagen füllen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „KI, Agenten und Hub“: Auftragsvorlagen mit Platzhaltern wie `{objekt}` füllen und fehlende Werte benennen, statt halbe Aufträge an das Modell zu schicken.

## Dateien
- `core/prompt_template.gd` – neu, Klasse `PromptTemplate`
- `tests/test_prompt_template.gd` – neu

## Akzeptanzkriterien
`class_name PromptTemplate`, `extends RefCounted`, nur statische Funktionen.
- `static func placeholders(template: String) -> Array[String]`: Namen aus `{name}` (`RegEx` mit `"\\{([a-z_]+)\\}"`, `search_all`), in der Reihenfolge des ersten Auftretens, ohne Doppelte
- `static func fill(template: String, values: Dictionary) -> Dictionary`: Platzhalter, die in `values` fehlen → `{"ok": false, "text": "", "missing": [...]}` (in der Reihenfolge von `placeholders`); sonst jeden `"{name}"` durch `str(values[name])` ersetzen → `{"ok": true, "text": ergebnis, "missing": []}`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs. Ergebnisse in `var result: Array[String] = []` sammeln.

## Tests
`tests/test_prompt_template.gd`, Vorlage `"Baue {objekt} in {szene}, dann {objekt} testen"`:
- `test_platzhalter`: `placeholders(vorlage)` ist `["objekt", "szene"]`; `placeholders("Hallo")` ist leer
- `test_fuellen`: `fill(vorlage, {"objekt": "Kiste", "szene": "start"})` hat `ok` wahr und `text` „Baue Kiste in start, dann Kiste testen“
- `test_fehlt`: `fill(vorlage, {"objekt": "Kiste"})` hat `ok` falsch und `missing` `["szene"]`
- `test_zahl`: `fill("{anzahl} Gegner", {"anzahl": 3})["text"]` ist „3 Gegner“; `fill("Hallo", {})["text"]` ist „Hallo“
