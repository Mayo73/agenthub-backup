---
id: T-0488
title: AiJob – KI-Auftrag mit Kontext, Provider, Fortschritt und Abbruch
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „KI, Agenten und Hub“ (Muss 9: „KI-Aufträge zeigen verwendeten Kontext, Provider, Fortschritt, Abbruchmöglichkeit und Änderungen“; „keine simulierte KI-Erfolgsmeldung“): ein Datenobjekt für einen KI-Auftrag.

## Dateien
- `core/ai_job.gd` – neu, Klasse `AiJob`
- `tests/test_ai_job.gd` – neu

## Akzeptanzkriterien
`class_name AiJob`, `extends RefCounted`.
- Zustände: `const WAITING := "wartet"`, `const RUNNING := "läuft"`, `const DONE := "fertig"`, `const FAILED := "fehlgeschlagen"`, `const CANCELLED := "abgebrochen"`, `const NO_PROVIDER := "kein_provider"`
- Felder: `var id := ""`, `var task := ""` (Auftrag in Worten), `var provider := ""`, `var context: Array[String] = []`, `var state := WAITING`, `var progress := 0.0`, `var changes: Array[Dictionary] = []` (je `{"command": String, "args": Dictionary}`), `var error := ""`
- `func _init(job_id: String = "", job_task: String = "") -> void`
- `func start(provider_id: String) -> bool`: nur aus `WAITING`; leerer `provider_id` → `state = NO_PROVIDER`, `error = "Kein KI-Modell erreichbar"`, `false`; sonst `RUNNING`, `true`
- `func report(value: float) -> void`: nur bei `RUNNING`, `progress = clampf(value, 0.0, 1.0)`
- `func add_change(command: String, args: Dictionary) -> void`: nur bei `RUNNING`
- `func finish() -> bool`: nur aus `RUNNING`; `DONE`, `progress = 1.0`
- `func fail(message: String) -> bool`: nur aus `RUNNING`
- `func cancel() -> bool`: aus `WAITING` oder `RUNNING` → `CANCELLED`; sonst `false`
- `func is_finished() -> bool`: Zustand ist `DONE`, `FAILED`, `CANCELLED` oder `NO_PROVIDER`
- `func summary() -> String`: `"%s · %s · %d %% · %d Änderungen" % [task, state, int(progress * 100), changes.size()]`, bei gesetztem `error` zusätzlich `" · " + error`
- `func to_dict() -> Dictionary` mit allen Feldern, `static func from_dict(d: Dictionary) -> AiJob` (Zahlen mit `float(...)`, Listen elementweise übernehmen)

## Tests
`tests/test_ai_job.gd`:
- `test_ablauf`: `AiJob.new("k1", "Spielfigur anlegen")`, `start("ollama")`, `report(0.5)`, `add_change("scene.add", {"type": "Node2D"})`, `finish()` → `state` „fertig“, `progress` 1.0, `changes.size()` 1
- `test_ohne_provider`: `start("")` → falsch, `state` `AiJob.NO_PROVIDER`, `summary()` enthält „Kein KI-Modell erreichbar“
- `test_abbruch`: nach `start("ollama")` `cancel()` → wahr, `is_finished()` wahr; danach `finish()` falsch
- `test_fortschritt_begrenzt`: `report(3.0)` im Lauf → `progress` 1.0; `report(0.5)` vor `start` ändert nichts (0.0)
- `test_speichern`: `AiJob.from_dict(job.to_dict())` hat gleichen `task`, `state`, `progress` und `changes.size()`

Review (21.10.2026): gemergt.
