---
id: T-0530
title: AiJobList – Liste der KI-Aufträge mit Abbruch und Speichern
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „KI, Agenten und Hub“ (Muss 9: Abbruchmöglichkeit, Fortschritt sichtbar): Alle KI-Aufträge einer Sitzung in einer Liste, mit fortlaufenden Kennungen, Abbruch und Übersicht.

## Dateien
- `core/ai_job_list.gd` – neu, Klasse `AiJobList`
- `tests/test_ai_job_list.gd` – neu

## Akzeptanzkriterien
`class_name AiJobList`, `extends RefCounted`. Vorher `core/ai_job.gd` lesen.
- `var jobs: Array[AiJob] = []`, `var next_no := 1`
- `func create(task: String) -> AiJob`: neuer `AiJob` mit `id` `"ki-%d" % next_no` (danach `next_no += 1`), hinten anhängen, zurückgeben
- `func find(id: String) -> AiJob`: der Auftrag mit dieser Kennung oder `null`
- `func cancel(id: String) -> CommandResult`: unbekannt → `CommandResult.error(CommandResult.NOT_FOUND, "Auftrag %s gibt es nicht" % id)`; liefert `job.cancel()` falsch → `CommandResult.error(CommandResult.CONFLICT, "Auftrag %s ist schon beendet" % id)`; sonst `success({"id": id})`
- `func running() -> Array[AiJob]`: alle, deren `is_finished()` falsch ist, in Listenreihenfolge
- `func lines() -> Array[String]`: je Auftrag `"%s: %s" % [job.id, job.summary()]`, neueste zuerst
- `func to_dict() -> Dictionary`: `{"next_no": next_no, "jobs": [job.to_dict() …]}`; `static func from_dict(d: Dictionary) -> AiJobList` (`next_no` mit `int(...)`, Aufträge mit `AiJob.from_dict`)

## Tests
`tests/test_ai_job_list.gd`:
- `test_kennungen`: zwei `create` → Kennungen „ki-1“ und „ki-2“, `find("ki-2").task` stimmt, `find("ki-9")` ist `null`
- `test_abbruch`: `create("A")`, `cancel("ki-1")` ok, `find("ki-1").state` `AiJob.CANCELLED`; nochmal `cancel("ki-1")` → Code `CommandResult.CONFLICT`; `cancel("ki-7")` → `CommandResult.NOT_FOUND`
- `test_laufend`: drei Aufträge, beim zweiten `start("ollama")` und `finish()` → `running().size()` 2
- `test_zeilen`: zwei Aufträge → `lines()[0]` beginnt mit „ki-2: “
- `test_speichern`: zwei Aufträge, `from_dict(to_dict())` hat 2 Aufträge und `next_no` 3; danach liefert `create` die Kennung „ki-3“

Review (21.10.2026): gemergt, nachgebessert: running() liefert ein typisiertes Array[AiJob], Tippfehler im Kommentar.
