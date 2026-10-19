---
id: T-0396
title: ModuleCommands – Module über Befehle auflisten, aktivieren und abschalten
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „Module“ (Lastenheft Muss 2 und 7): Was die `ModuleRegistry` kann, muss auch über das gemeinsame Befehlsmodell gehen, damit GUI, CLI und Agenten Module gleich verwalten.

## Dateien
- `core/module_commands.gd` – neu, Klasse `ModuleCommands`
- `tests/test_module_commands.gd` – neu

## Akzeptanzkriterien
`class_name ModuleCommands`, `extends RefCounted`:
- `static func register_all(commands: CommandRegistry, modules: ModuleRegistry) -> void` registriert drei Befehle (Parameter-Typen wie in `CommandRegistry`):
  - `"module.list"`, Beschreibung „Module mit Version, Abhängigkeiten und Zustand auflisten“, Parameter `{}` → `CommandResult.success({"modules": modules.list()})`
  - `"module.enable"`, Beschreibung „Modul aktivieren“, Parameter `{"id": "string"}` → Ergebnis von `modules.enable(id)` unverändert zurückgeben
  - `"module.disable"`, Beschreibung „Modul abschalten“, Parameter `{"id": "string"}` → Ergebnis von `modules.disable(id)` unverändert zurückgeben
- Die Handler sind Lambdas `func(args: Dictionary) -> CommandResult`, die `modules` aus dem Aufruf von `register_all` nutzen. Den `id`-Wert mit `var id: String = str(args["id"])` lesen.

## Tests
`tests/test_module_commands.gd`, `setup()`: `CommandRegistry.new()`, `ModuleRegistry.new()`, Module `physik` (Name „Physik“, Version „1.0.0“, `optional = false`) und `beispiel` (Name „Beispiel“, Version „1.0.0“) per `add` aufnehmen, dann `ModuleCommands.register_all(...)`.
- `test_registriert`: `has_command` für alle drei Namen wahr
- `test_liste`: `execute("module.list", {})` ok, `data["modules"].size()` 2, erster Eintrag `id` „beispiel“
- `test_aktivieren`: `execute("module.enable", {"id": "beispiel"})` ok, danach `is_enabled("beispiel")` wahr
- `test_unbekannt`: `execute("module.enable", {"id": "gibtsnicht"})` → `code` „not_found“
- `test_notwendig`: `physik` aktivieren, `execute("module.disable", {"id": "physik"})` → `code` „dependency“, `message` „Modul physik ist notwendig“
- `test_parameter_fehlt`: `execute("module.enable", {})` → `code` „invalid_argument“

Review (19.10.2026): gemergt, nachgebessert: Docstring mit drei Anführungszeichen durch Kommentar ersetzt.
