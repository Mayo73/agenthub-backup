---
id: T-0408
title: ProjectCommands – Projekte über Befehle speichern und öffnen
project: hub-engine
priority: 3
after: T-0389
---
## Ziel
Meilenstein „Durchstich“ (Muss 1 und 7, Abnahmekriterien 1 und 4): Speichern und Öffnen über dieselben Befehle für Oberfläche, CLI und Agenten.

## Dateien
- `core/project_commands.gd` – neu, Klasse `ProjectCommands`
- `tests/test_project_commands.gd` – neu

## Akzeptanzkriterien
`class_name ProjectCommands`, `extends RefCounted`. Nutzt `ProjectStore` (`core/project_store.gd`, vorher lesen) und `SceneModel`.
- `var store: ProjectStore`, `var model: SceneModel`, `var name := ""`, `var path := ""`, `var modules: Array[String] = []`
- `static func register_all(commands: CommandRegistry, project_store: ProjectStore, scene: SceneModel) -> ProjectCommands`: Instanz anlegen, `store` und `model` setzen, Befehle mit Lambdas registrieren (die Lambdas nutzen die Instanz), Instanz zurückgeben:
  - `"project.save"`, „Projekt speichern“, `{"path": "string", "name": "string"}` → `store.save(path, name, model, modules)`; bei Erfolg `path` und `name` der Instanz setzen; Ergebnis zurückgeben
  - `"project.open"`, „Projekt öffnen“, `{"path": "string"}` → `store.open(path)`; bei Erfolg die geladene Szene mit `model.load_from(geladen.to_dict())` übernehmen (das Modell-Objekt bleibt dasselbe, damit andere Befehle es weiter nutzen), `name`, `modules` und `path` setzen, `success({"name": name, "objects": model.order.size()})`; sonst das Fehlerergebnis
  - `"project.info"`, „Projektangaben abfragen“, `{}` → `success({"name": name, "path": path, "objects": model.order.size()})`

## Tests
`tests/test_project_commands.gd`, Dateien nur unter `user://test_project_commands/`, in `teardown()` Dateien und Ordner löschen. `setup()`: `guard = PathGuard.new()`, `guard.add_root("user://test_project_commands")`, `model = SceneModel.new()`, `registry = CommandRegistry.new()`, `cmds = ProjectCommands.register_all(registry, ProjectStore.new(guard), model)`:
- `test_speichern_oeffnen`: `model.add_object("Node2D")`; `project.save` mit `{"path": "user://test_project_commands/a.json", "name": "Demo"}` ok; `model.load_from(SceneModel.new().to_dict())`; `project.open` mit demselben Pfad ok, `data["objects"]` 1, `model.has_object("o1")` wahr
- `test_verbotener_pfad`: `project.save` nach „user://anderswo/a.json“ → `code` „forbidden_path“
- `test_fehlt`: `project.open` „user://test_project_commands/fehlt.json“ → „not_found“
- `test_info`: nach dem Speichern `project.info` → `data["name"]` „Demo“

Review (19.10.2026): gemergt.
