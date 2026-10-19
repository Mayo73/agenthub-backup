---
id: T-0409
title: EditorCommands – Auswahl und Suche über Befehle
project: hub-engine
priority: 3
after: T-0393
---
## Ziel
Meilenstein „Durchstich“ (Muss 3 und 7): Was die Oberfläche bei Auswahl und Suche tut, können Agenten über Befehle ebenso.

## Dateien
- `core/editor_commands.gd` – neu, Klasse `EditorCommands`
- `tests/test_editor_commands.gd` – neu

## Akzeptanzkriterien
`class_name EditorCommands`, `extends RefCounted`. Nutzt `EditorSession` (`core/editor_session.gd`, vorher lesen).
- `static func register_all(commands: CommandRegistry, session: EditorSession) -> void` registriert mit Lambdas `func(args: Dictionary) -> CommandResult`:
  - `"editor.select"`, „Objekt auswählen“, `{"id": "string"}` → `session.select(id)` falsch → `NOT_FOUND`, `"Objekt %s gibt es nicht"`; sonst `success({"selected": session.selected})`
  - `"editor.selection"`, „Ausgewähltes Objekt abfragen“, `{}` → `success({"selected": session.selected, "object": session.selected_object()})`
  - `"editor.search"`, „Objekte suchen“, `{"text": "string"}` → `success({"ids": session.search(text)})`
  - `"editor.path"`, „Pfad eines Objekts im Szenenbaum“, `{"id": "string"}` → leerer Pfad → `NOT_FOUND`, `"Objekt %s gibt es nicht"`; sonst `success({"path": pfad})`

## Tests
`tests/test_editor_commands.gd`, `setup()`: `model = SceneModel.new()`, `model.add_object("Node2D", "", {"name": "Welt"})` (o1), `model.add_object("Sprite2D", "o1", {"name": "Spieler"})` (o2), `session = EditorSession.new(model)`, `registry = CommandRegistry.new()`, `EditorCommands.register_all(registry, session)`:
- `test_auswahl`: `editor.select` „o2“ ok; `editor.selection` → `data["selected"]` „o2“
- `test_unbekannt`: `editor.select` „o9“ → „not_found“
- `test_suche`: `editor.search` mit `{"text": "spieler"}` → `data["ids"]` `["o2"]`
- `test_pfad`: `editor.path` „o2“ → `data["path"]` `["o1", "o2"]`; „o9“ → „not_found“
