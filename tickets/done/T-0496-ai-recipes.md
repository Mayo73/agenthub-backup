---
id: T-0496
title: AiRecipes – erprobte KI-Rezepte für wiederkehrende Aufgaben
project: hub-engine
priority: 4
---
## Ziel
Lastenheft „Soll“: „Erprobte KI-Rezepte für wiederkehrende Aufgaben wie Spielfigur, Kamera, Hindernisse, Auslöser und Testlauf“. Ein Rezept ist eine Vorlage für den Auftrag an das KI-Modell mit Platzhaltern, die der Nutzer oder Agent ausfüllt.

## Dateien
- `core/ai_recipes.gd` – neu, Klasse `AiRecipes`
- `tests/test_ai_recipes.gd` – neu

## Akzeptanzkriterien
`class_name AiRecipes`, `extends RefCounted`, nur statische Funktionen.
- `const RECIPES := {...}`: je Name `{"title": String, "template": String, "defaults": Dictionary}`. Platzhalter im Text als `{name}`. Mindestens diese fünf (deutsche Texte, sinngemäß):
  - `"spielfigur"`: „Lege eine steuerbare Spielfigur namens {name} an, Geschwindigkeit {tempo} Einheiten/s, Sprunghöhe {sprung} Einheiten.“ (Standard `tempo` 5, `sprung` 2)
  - `"kamera"`: „Lass die Kamera {ziel} folgen, Totzone {totzone} Einheiten.“ (Standard `totzone` 2)
  - `"hindernisse"`: „Verteile {anzahl} Hindernisse zwischen x={von} und x={bis}.“ (Standard `anzahl` 5)
  - `"ausloeser"`: „Lege einen Auslösebereich {name} an, der beim Betreten {aktion} auslöst.“
  - `"testlauf"`: „Schreibe einen Testlauf: {eingaben}. Erwartet: {erwartung}.“
- `static func names() -> Array[String]`: sortiert
- `static func placeholders(name: String) -> Array[String]`: alle `{…}`-Namen des Rezepts, sortiert, ohne Doppelte (unbekanntes Rezept → leer)
- `static func fill(name: String, values: Dictionary) -> CommandResult`: unbekannt → `NOT_FOUND`, `"Rezept %s gibt es nicht"`; Werte = `defaults` überschrieben mit `values`; fehlen danach Platzhalter → `INVALID_ARGUMENT`, `"Es fehlen: " + fehlende mit ", "`; sonst `success({"prompt": Text mit ersetzten Platzhaltern, "title": title})`

## Tests
`tests/test_ai_recipes.gd`:
- `test_namen`: `names()` enthält alle fünf Rezepte, sortiert
- `test_platzhalter`: `placeholders("spielfigur")` ist `["name", "sprung", "tempo"]`
- `test_ausfuellen`: `fill("spielfigur", {"name": "Held"})` ok, `prompt` enthält „Held“ und „5 Einheiten/s“
- `test_fehlt`: `fill("ausloeser", {"name": "Tor"})` → „invalid_argument“, Meldung enthält „aktion“
- `test_unbekannt`: `fill("zaubern", {})` → „not_found“

Review (21.10.2026): selbst umgesetzt (Agent scheiterte 5x an Typ-Inferenz im Test), Commit im Projekt.
