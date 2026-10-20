---
id: T-0424
title: CommandPlan – Befehlsfolgen aus KI-Antworten lesen, prüfen und ausführen
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „KI, Agenten und Hub“ (Muss 9: aus natürlicher Sprache ein Szenenarrangement erzeugen, Entwürfe vor Übernahme prüfen; Abnahmekriterium 11): Ein KI-Modell antwortet mit einer JSON-Liste von Befehlen. Diese Klasse liest die Liste, prüft sie gegen das Befehlsverzeichnis und führt sie erst dann aus, mit Abbruch beim ersten Fehler.

## Dateien
- `core/command_plan.gd` – neu, Klasse `CommandPlan`
- `tests/test_command_plan.gd` – neu

## Akzeptanzkriterien
`class_name CommandPlan`, `extends RefCounted`, nur statische Funktionen. Nutzt `CommandRegistry` (`core/command_registry.gd`, vorher lesen).
- `static func extract_json(text: String) -> String`: steht im Text ein Block zwischen drei Backticks (optional mit `json` dahinter), dessen Inhalt; sonst der Text ab dem ersten `[` bis einschließlich zum letzten `]`; sonst „“
- `static func parse(text: String) -> CommandResult`: `JSON.parse_string(extract_json(text))` muss ein `Array` sein, jedes Element ein Dictionary mit `"command"` (String) und optional `"args"` (Dictionary, Standard `{}`). Sonst `INVALID_ARGUMENT`, `"Antwort enthält keinen gültigen Befehlsplan"`. Erfolg: `success({"steps": Array[Dictionary]})` mit je `{"command", "args"}`
- `static func check(registry: CommandRegistry, steps: Array[Dictionary]) -> Array[String]`: je Schritt (Nummer ab 1), dessen Befehl `registry.has_command` nicht kennt → `"Schritt %d: Befehl %s gibt es nicht"`
- `static func run(registry: CommandRegistry, steps: Array[Dictionary]) -> CommandResult`: Probleme aus `check` → `INVALID_ARGUMENT` mit Problemen durch „; “ verbunden, nichts ausführen. Sonst nacheinander `registry.execute`; beim ersten Fehler `CommandResult.error(ergebnis.code, "Schritt %d: %s" % [n, ergebnis.message], {"done": n - 1})`; alle gut → `success({"done": steps.size(), "results": Liste der data})`

## Tests
`tests/test_command_plan.gd`, `setup()`: `registry = CommandRegistry.new()`, `model = SceneModel.new()`, `SceneCommands.register_all(registry, model)`:
- `test_json_block`: `extract_json("Hier:\n```json\n[{\"command\": \"x\"}]\n```")` ist `[{"command": "x"}]` (Leerraum mit `strip_edges()` entfernt)
- `test_lesen`: `parse("[{\"command\": \"scene.list\", \"args\": {\"parent\": \"\"}}]")` ok, `data["steps"].size()` 1
- `test_ungueltig`: `parse("keine Ahnung")` → „invalid_argument“
- `test_unbekannt`: `run` mit Schritt `{"command": "zaubern", "args": {}}` → „invalid_argument“, Meldung „Schritt 1: Befehl zaubern gibt es nicht“, `model.order.size()` 0
- `test_ausfuehren`: zwei Schritte `scene.add` (`{"type": "Node2D", "parent": "", "props": {}}`) → ok, `data["done"]` 2, `model.order.size()` 2
- `test_abbruch`: `scene.add` gültig, dann `scene.remove` `{"id": "o9"}`, dann nochmal `scene.add` → `code` „not_found“, `data["done"]` 1, `model.order.size()` 1

Review (19.10.2026): gemergt.
