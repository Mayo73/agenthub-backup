---
id: T-0490
title: PromptContext – Kontext für KI-Hilfe aus Szene, Auswahl und Fehler
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „KI, Agenten und Hub“ (Muss 9: „Kontextbezogene Hilfe zu ausgewähltem Objekt, Szene und Fehler“; KI-Aufträge zeigen den verwendeten Kontext): Diese Klasse stellt den Kontext als Textzeilen zusammen.

## Dateien
- `core/prompt_context.gd` – neu, Klasse `PromptContext`
- `tests/test_prompt_context.gd` – neu

## Akzeptanzkriterien
`class_name PromptContext`, `extends RefCounted`, nur statische Funktionen. Vorher `core/scene_model.gd` lesen (`order`, `get_object`, `children`, `get_property`).
- `const MAX_OBJECTS := 30`
- `static func object_line(model: SceneModel, id: String) -> String`: `"%s (%s)" % [id, typ]` und, wenn das Objekt Eigenschaften hat, `": " + ` die Eigenschaften als `schlüssel=wert`, nach Schlüssel sortiert, mit `", "` verbunden. Typ und Eigenschaften so lesen, wie `SceneModel` sie im Objekt-Dictionary ablegt (vorher nachsehen).
- `static func scene_lines(model: SceneModel) -> Array[String]`: erste Zeile `"Szene: %d Objekte" % model.order.size()`, dann je Objekt in `model.order` `"- " + object_line(...)`, höchstens `MAX_OBJECTS` Objekte; gibt es mehr, als letzte Zeile `"… und %d weitere" % rest`
- `static func build(model: SceneModel, selected: String = "", last_error: String = "") -> Array[String]`: zuerst `scene_lines`, dann bei existierender Auswahl `"Ausgewählt: " + object_line(model, selected)`, dann bei nicht leerem Fehler `"Letzter Fehler: " + last_error`
- `static func as_text(lines: Array[String]) -> String`: Zeilen mit `"\n"` verbunden

## Tests
`tests/test_prompt_context.gd`, `setup()`: `model = SceneModel.new()`, zwei Objekte mit `model.add_object("Node2D")` und `model.add_object("Sprite2D", "", {"textur": "held.png", "x": 3})`:
- `test_szene`: `scene_lines(model)` hat 3 Zeilen, erste „Szene: 2 Objekte“
- `test_zeile`: `object_line(model, <id des Sprites>)` enthält „Sprite2D“, „textur=held.png“ und „x=3“, und „textur“ steht vor „x“
- `test_auswahl_und_fehler`: `build(model, <id des Sprites>, "Datei fehlt")` → vorletzte Zeile beginnt mit „Ausgewählt: “, letzte ist „Letzter Fehler: Datei fehlt“
- `test_ohne_auswahl`: `build(model, "gibtsnicht")` hat 3 Zeilen
- `test_begrenzt`: 40 Objekte → `scene_lines` hat 32 Zeilen, letzte „… und 10 weitere“

Review (21.10.2026): gemergt.
