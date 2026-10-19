---
id: T-0375
title: SceneCommands – Szenenbefehle scene.add/remove/set/get/list/duplicate
project: hub-engine
priority: 4
after: T-0373, T-0374
---
## Ziel
Meilenstein „Kern: Befehle, Szenen, Revisionen“ (Abnahmekriterium 3: jede Funktion als strukturierter Befehl): die Bearbeitung des Szenenmodells als Befehle, die GUI, CLI und Agenten gleich aufrufen.

## Dateien
- `core/scene_commands.gd` – neu, Klasse `SceneCommands`
- `tests/test_scene_commands.gd` – neu

## Akzeptanzkriterien
`class_name SceneCommands`, `extends RefCounted`:
- `var model: SceneModel`
- `static func register_all(registry: CommandRegistry, scene: SceneModel) -> SceneCommands`: legt eine Instanz an (`model = scene`), registriert die Befehle mit Handlern dieser Instanz und gibt sie zurück:
  - `"scene.add"` `{"type": "string", "parent": "string", "props": "dict"}` → `success({"id": id})`; scheitert `add_object` (leere Kennung) → `NOT_FOUND`, `"Elternobjekt %s gibt es nicht"`
  - `"scene.remove"` `{"id": "string"}` → `success({"id": id})` oder `NOT_FOUND`, `"Objekt %s gibt es nicht"`
  - `"scene.set"` `{"id": "string", "key": "string", "value": "any"}` → `success({"id", "key", "value"})` oder `NOT_FOUND` wie oben
  - `"scene.get"` `{"id": "string"}` → `success(model.get_object(id))` oder `NOT_FOUND`
  - `"scene.list"` `{"parent": "string"}` → `success({"ids": model.children(parent)})`
  - `"scene.duplicate"` `{"id": "string"}` → `success({"id": neue Kennung})` oder `NOT_FOUND`
- Jede Beschreibung ist ein deutscher Satz (z. B. „Legt ein Objekt in der Szene an.“).

## Tests
`tests/test_scene_commands.gd`, in `setup()` `registry = CommandRegistry.new()`, `model = SceneModel.new()`, `SceneCommands.register_all(registry, model)`:
- `test_anlegen`: `execute("scene.add", {"type": "Node2D", "parent": "", "props": {}})` → ok, `data["id"]` „o1“, `model.has_object("o1")`
- `test_eltern_fehlt`: `scene.add` mit `"parent": "o9"` → Code „not_found“
- `test_setzen_und_lesen`: anlegen, `scene.set` `{"id": "o1", "key": "mass", "value": 3.0}` → ok; `scene.get` → `data["props"]["mass"]` 3.0
- `test_entfernen`: anlegen, `scene.remove` → ok, danach `scene.get` → „not_found“
- `test_liste_und_kopie`: anlegen, `scene.duplicate` `{"id": "o1"}` → `data["id"]` „o2“; `scene.list` `{"parent": ""}` → `data["ids"]` `["o1", "o2"]`
- `test_verzeichnis`: `registry.capabilities().size()` 6, jeder Eintrag hat eine nicht leere `description`

Review (19.10.2026): gemergt, nachgebessert: Docstring mit drei Anführungszeichen durch Kommentar ersetzt.
