---
id: T-0405
title: CapabilityDoc – Fähigkeitenverzeichnis als Markdown erzeugen
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „Kern“ (Abnahmekriterium 3): Aus dem `CommandRegistry` eine Markdown-Tabelle aller Befehle erzeugen, damit das Fähigkeitenverzeichnis immer zum Code passt.

## Dateien
- `core/capability_doc.gd` – neu, Klasse `CapabilityDoc`
- `tests/test_capability_doc.gd` – neu

## Akzeptanzkriterien
`class_name CapabilityDoc`, `extends RefCounted`, nur statische Funktionen. Nutzt `registry.capabilities()` (Einträge `{"name", "description", "params"}`, nach Name sortiert; vorher `core/command_registry.gd` lesen).
- `static func params_text(params: Dictionary) -> String`: Schlüssel sortiert, je `"name: typ"`, mit `", "` verbunden; leeres Dictionary → `"–"`
- `static func group_of(name: String) -> String`: Teil vor dem ersten Punkt (`"scene.add"` → `"scene"`), ohne Punkt der ganze Name
- `static func markdown(registry: CommandRegistry) -> String`: diese Zeilen, mit Zeilenumbruch verbunden:
  1. `# Fähigkeitenverzeichnis`
  2. leere Zeile
  3. `| Befehl | Gruppe | Parameter | Beschreibung |`
  4. `|---|---|---|---|`
  5. je Befehl `"| %s | %s | %s | %s |" % [name, group_of(name), params_text(params), description]`
- `static func groups(registry: CommandRegistry) -> Array[String]`: alle Gruppen sortiert, ohne Doppelte

## Tests
`tests/test_capability_doc.gd`, Registry mit zwei Befehlen: `"scene.add"` (Parameter `{"type": "string", "parent": "string"}`) und `"sim.start"` (Parameter `{}`), Handler jeweils `func(args: Dictionary) -> CommandResult: return CommandResult.success()`:
- `test_parameter`: `params_text({"type": "string", "parent": "string"})` ist „parent: string, type: string“; `params_text({})` ist „–“
- `test_gruppe`: `group_of("scene.add")` „scene“, `group_of("hilfe")` „hilfe“
- `test_tabelle`: `markdown(registry).split("\n")` hat 6 Zeilen; Zeile mit Index 4 beginnt mit „| scene.add | scene |“
- `test_gruppen`: `groups(registry)` ist `["scene", "sim"]`
