---
id: T-0410
title: TemplateCommands – Vorlagen auflisten und eine Szene daraus anlegen
project: hub-engine
priority: 3
after: T-0392
---
## Ziel
Meilenstein „Durchstich“ (Muss 1 und 3: aus einer Vorlage starten): Vorlagen über Befehle auflisten und das aktuelle Szenenmodell daraus füllen.

## Dateien
- `core/template_commands.gd` – neu, Klasse `TemplateCommands`
- `tests/test_template_commands.gd` – neu

## Akzeptanzkriterien
`class_name TemplateCommands`, `extends RefCounted`. Nutzt `ProjectTemplates` (`core/project_templates.gd`, vorher lesen).
- `static func register_all(commands: CommandRegistry, scene: SceneModel) -> void` registriert mit Lambdas `func(args: Dictionary) -> CommandResult`:
  - `"template.list"`, „Projektvorlagen auflisten“, `{}` → `success({"templates": liste})`; `liste` ist ein `Array[Dictionary]` mit `ProjectTemplates.describe(name)` für jeden Namen aus `ProjectTemplates.names()`
  - `"template.apply"`, „Szene aus einer Vorlage anlegen“, `{"name": "string"}` → ist `ProjectTemplates.create(name)` `null` → `NOT_FOUND`, `"Vorlage %s gibt es nicht"`, Szene unverändert; sonst `scene.load_from(neu.to_dict())`, `success({"name": name, "objects": scene.order.size()})`

## Tests
`tests/test_template_commands.gd`, `setup()`: `model = SceneModel.new()`, `registry = CommandRegistry.new()`, `TemplateCommands.register_all(registry, model)`:
- `test_liste`: `template.list` → `data["templates"].size()` 2, erster Eintrag `name` „leer_2d“
- `test_anwenden_2d`: `template.apply` „leer_2d“ ok, `data["objects"]` 3, `model.order.size()` 3
- `test_anwenden_3d`: „leer_3d“ → `data["objects"]` 4
- `test_unbekannt`: „gibts“ → „not_found“, `model.order.size()` 0

Review (19.10.2026): gemergt, nachgebessert: verdeckte Klassennamen (static var … = load) entfernt, Liste typisiert.
