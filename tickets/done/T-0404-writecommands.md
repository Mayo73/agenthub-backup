---
id: T-0404
title: WriteCommands – Eigenschaften mit Ausgangsrevision über Befehle ändern
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „Kern“ (Muss 8, Abnahmekriterium 10): Agenten, CLI und Oberfläche ändern Eigenschaften über den Schreibkoordinator, damit Konflikte als Fehler `conflict` sichtbar werden statt still zu überschreiben.

## Dateien
- `core/write_commands.gd` – neu, Klasse `WriteCommands`
- `tests/test_write_commands.gd` – neu

## Akzeptanzkriterien
`class_name WriteCommands`, `extends RefCounted`. Nutzt `CommandRegistry` (`core/command_registry.gd`) und `WriteCoordinator` (`core/write_coordinator.gd`), beide vorher lesen.
- `static func register_all(commands: CommandRegistry, coordinator: WriteCoordinator) -> void` registriert mit Lambdas `func(args: Dictionary) -> CommandResult`:
  - `"write.set"`, Beschreibung „Eigenschaft mit Ausgangsrevision ändern“, Parameter `{"id": "string", "key": "string", "value": "any", "base": "number", "author": "string"}` → Ergebnis von `coordinator.set_property(id, key, value, int(args["base"]), author)` unverändert zurückgeben
  - `"write.revision"`, Beschreibung „Aktuelle Revision abfragen“, Parameter `{}` → `success({"revision": coordinator.revision})`
  - `"write.history"`, Beschreibung „Änderungsverlauf eines Objekts“, Parameter `{"id": "string"}` → `success({"entries": coordinator.history(id)})`
- Strings mit `var id: String = str(args["id"])` lesen.

## Tests
`tests/test_write_commands.gd`, in `setup()`: `model = SceneModel.new()`, `model.add_object("RigidBody2D", "", {"mass": 1.0})`, `coord = WriteCoordinator.new(model)`, `registry = CommandRegistry.new()`, `WriteCommands.register_all(registry, coord)`:
- `test_setzen`: `registry.execute("write.set", {"id": "o1", "key": "mass", "value": 2.0, "base": 0, "author": "gui"})` ok; `model.get_property("o1", "mass")` 2.0
- `test_konflikt`: zweimal `write.set` mit `mass` auf Basis 0 (Autoren „gui“, dann „agent“) → zweites Ergebnis `code` „conflict“, Modell weiter beim ersten Wert
- `test_revision`: nach einer Änderung `execute("write.revision", {}).data["revision"]` 1
- `test_verlauf`: Änderungen auf Basis 0 und dann Basis 1 → `execute("write.history", {"id": "o1"}).data["entries"].size()` 2

Review (19.10.2026): gemergt.
