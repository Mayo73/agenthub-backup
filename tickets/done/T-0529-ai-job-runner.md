---
id: T-0529
title: AiJobRunner – Befehlsplan einer KI-Antwort als Auftrag ausführen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „KI, Agenten und Hub“ (Muss 9: KI-Aufträge zeigen Fortschritt und Änderungen, keine simulierte Erfolgsmeldung): Die Antwort eines Modells wird als Befehlsplan gelesen und Schritt für Schritt ausgeführt; der `AiJob` hält Fortschritt, Änderungen und Fehler fest.

## Dateien
- `core/ai_job_runner.gd` – neu, Klasse `AiJobRunner`
- `tests/test_ai_job_runner.gd` – neu

## Akzeptanzkriterien
`class_name AiJobRunner`, `extends RefCounted`, nur statische Funktionen. Vorher `core/ai_job.gd`, `core/command_plan.gd` (`parse`, `check`) und `core/command_registry.gd` (`execute`) lesen.
- `static func apply(job: AiJob, registry: CommandRegistry, answer: String) -> CommandResult`:
  - Ist `job.state` nicht `AiJob.RUNNING` → `CommandResult.error(CommandResult.CONFLICT, "Auftrag läuft nicht")`, am Auftrag nichts ändern
  - `CommandPlan.parse(answer)`; Fehler → `job.fail(ergebnis.message)` und genau dieses Fehlerergebnis zurückgeben
  - `steps: Array[Dictionary]` aus `data["steps"]` lesen (elementweise in ein typisiertes Array übernehmen); liefert `CommandPlan.check(registry, steps)` Probleme → `job.fail("; ".join(probleme))` und `CommandResult.error(CommandResult.INVALID_ARGUMENT, …)` mit demselben Text; dann wird **kein** Schritt ausgeführt
  - Schritte der Reihe nach mit `registry.execute(command, args)` ausführen. Nach jedem erfolgreichen Schritt `job.add_change(command, args)` und `job.report(float(i + 1) / steps.size())`
  - Schlägt Schritt `i` fehl: `job.fail("Schritt %d: %s" % [i + 1, ergebnis.message])` und `CommandResult.error(ergebnis.code, dieselbe Meldung, {"done": i})`
  - Alles gut: `job.finish()`, `CommandResult.success({"done": steps.size()}, "%d Befehle ausgeführt" % steps.size())`
  - Leerer Plan (`[]`): `job.finish()`, `success({"done": 0})`

## Tests
`tests/test_ai_job_runner.gd`, `setup()`: `registry = CommandRegistry.new()`, `model = SceneModel.new()`, `SceneCommands.register_all(registry, model)` (wie in `tests/test_mcp_tools.gd`), `job = AiJob.new("k1", "Test")`, `job.start("ollama")`:
- `test_erfolg`: Antwort `[{"command": "scene.add", "args": {"type": "Node2D", "parent": "", "props": {}}}]` (als String in einfachen Anführungszeichen) → ok, `job.state` `AiJob.DONE`, `job.changes.size()` 1, `model.order.size()` 1, `job.progress` 1.0
- `test_kein_plan`: Antwort „Ich weiß nicht“ → nicht ok, `job.state` `AiJob.FAILED`, `job.error` nicht leer
- `test_unbekannter_befehl`: `[{"command": "zaubern", "args": {}}, {"command": "scene.add", "args": {"type": "Node2D", "parent": "", "props": {}}}]` → nicht ok, `job.state` `AiJob.FAILED`, `model.order.size()` 0 (nichts ausgeführt)
- `test_nicht_gestartet`: neuer `AiJob` ohne `start` → Code `CommandResult.CONFLICT`, `state` bleibt `AiJob.WAITING`
- `test_leerer_plan`: Antwort `[]` → ok, `job.state` `AiJob.DONE`

Review (21.10.2026): gemergt.
