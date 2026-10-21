---
id: T-0551
title: HelpTopics – kontextbezogene Hilfe und Suche
project: hub-engine
priority: 4
---
## Ziel
Muss 3 „kontextbezogene Hilfe“: Hilfetexte, die der Editor je nach Bereich (Editor, Projekt, Export …) anzeigt und die man durchsuchen kann. Auch Agenten können sie abfragen.

## Dateien
- `core/help_topics.gd` – neu, Klasse `HelpTopics`
- `tests/test_help_topics.gd` – neu

## Akzeptanzkriterien
`class_name HelpTopics`, `extends RefCounted`.
- `var topics: Dictionary = {}` (Kennung → `{"id": String, "title": String, "text": String, "contexts": Array}`)
- `func add(id: String, title: String, text: String, contexts: Array[String]) -> void`
- `func for_context(context: String) -> Array[String]`: Kennungen aller Themen mit diesem Kontext, sortiert nach Titel
- `func search(query: String) -> Array[String]`: leerer `query` → leer; sonst Kennungen aller Themen, deren Titel oder Text `query` enthält, ohne Groß- und Kleinschreibung (`to_lower()`), sortiert nach Kennung
- `func text_of(id: String) -> String`: Text oder ""
- `func lines(context: String) -> Array[String]`: für `for_context(context)` je `"%s: %s" % [titel, text]`

Hinweis Typen: Werte aus Dictionaries immer mit Typ lesen (`var t: Dictionary = topics[id]`, `var ctx: Array = t["contexts"]`); Ergebnisse in `var result: Array[String] = []` sammeln.

## Tests
`tests/test_help_topics.gd`, `setup()`: `help = HelpTopics.new()` mit
`help.add("speichern", "Speichern", "Strg+S speichert das Projekt.", ["editor", "projekt"])`,
`help.add("export", "Exportieren", "Erstellt ein Windows-Spiel.", ["projekt"])`,
`help.add("auswahl", "Auswählen", "Klick wählt ein Objekt.", ["editor"])`:
- `test_kontext`: `for_context("projekt")` ist `["export", "speichern"]`, `for_context("editor")` ist `["auswahl", "speichern"]`, `for_context("x")` leer
- `test_suche`: `search("WINDOWS")` ist `["export"]`, `search("objekt")` ist `["auswahl"]`, `search("")` leer
- `test_zeilen`: `lines("projekt")[0]` ist „Exportieren: Erstellt ein Windows-Spiel.“
- `test_text`: `text_of("export")` „Erstellt ein Windows-Spiel.“, `text_of("nix")` ""

Review (21.10.2026): gemergt.
