---
id: T-0605
title: AgentPermissions – welcher Agent welche Befehlsgruppen nutzen darf
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „KI, Agenten und Hub“ (Abnahmekriterien 4 und 15): Jedem angebundenen Agenten Befehlsgruppen freigeben und Befehle außerhalb der Freigabe verständlich abweisen.

## Dateien
- `core/agent_permissions.gd` – neu, Klasse `AgentPermissions`
- `tests/test_agent_permissions.gd` – neu

## Akzeptanzkriterien
`class_name AgentPermissions`, `extends RefCounted`. Vorher `core/command_result.gd` und `core/capability_doc.gd` lesen (`CapabilityDoc.group_of("scene.add")` ist „scene“).
- `var grants: Dictionary = {}` (Agent → `Array` von Gruppennamen)
- `func grant(agent: String, group: String) -> void`: Gruppe ergänzen, keine Doppelten
- `func revoke(agent: String, group: String) -> void`
- `func groups_of(agent: String) -> Array[String]`: sortiert, unbekannter Agent → `[]`
- `func allowed(agent: String, command: String) -> bool`: Gruppe `"*"` erlaubt alles; sonst muss `CapabilityDoc.group_of(command)` freigegeben sein
- `func check(agent: String, command: String) -> CommandResult`: erlaubt → `CommandResult.success({"agent": agent, "command": command})`; sonst `CommandResult.error(CommandResult.INVALID_ARGUMENT, "Agent %s darf %s nicht ausführen (Gruppe %s ist nicht freigegeben)" % [agent, command, gruppe])`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs. Werte aus Dictionaries mit Typ lesen (`var list: Array = grants.get(agent, [])`).

## Tests
`tests/test_agent_permissions.gd`, in `setup()`: `perm = AgentPermissions.new()`, `perm.grant("ollama", "scene")`, `perm.grant("ollama", "sim")`:
- `test_erlaubt`: `allowed("ollama", "scene.add")` wahr, `allowed("ollama", "export.run")` falsch, `allowed("claude", "scene.add")` falsch
- `test_meldung`: `var r: CommandResult = perm.check("ollama", "export.run")` hat Code „invalid_argument“ und die Meldung enthält „export“; `check("ollama", "sim.step").code` „ok“
- `test_alles`: `grant("claude", "*")` → `allowed("claude", "export.run")` wahr
- `test_gruppen`: `grant("ollama", "scene")` nochmal → `groups_of("ollama")` ist `["scene", "sim"]`; nach `revoke("ollama", "sim")` ist es `["scene"]`; `groups_of("unbekannt")` leer
