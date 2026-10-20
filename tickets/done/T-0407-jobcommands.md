---
id: T-0407
title: JobCommands – Aufträge über Befehle anlegen, beobachten und abbrechen
project: hub-engine
priority: 3
after: T-0391
---
## Ziel
Meilenstein „Durchstich“ (Muss 7 und 11, Abnahmekriterium 14): Agenten und Hub legen Aufträge (z. B. Export, Test) über Befehle an, fragen den Fortschritt ab und brechen sie ab.

## Dateien
- `core/job_commands.gd` – neu, Klasse `JobCommands`
- `tests/test_job_commands.gd` – neu

## Akzeptanzkriterien
`class_name JobCommands`, `extends RefCounted`. Nutzt `CommandRegistry` und `JobQueue` (`core/job_queue.gd`, vorher lesen).
- `static func register_all(commands: CommandRegistry, queue: JobQueue) -> void` registriert mit Lambdas `func(args: Dictionary) -> CommandResult`:
  - `"job.submit"`, „Auftrag anlegen“, `{"kind": "string", "params": "dict"}` → `success({"id": queue.submit(kind, params)})`
  - `"job.status"`, „Zustand eines Auftrags abfragen“, `{"id": "string"}` → ist `queue.get_job(id)` leer → `NOT_FOUND`, `"Auftrag %s gibt es nicht"`; sonst `success(job)`
  - `"job.cancel"`, „Auftrag abbrechen“, `{"id": "string"}` → Ergebnis von `queue.cancel(id)` unverändert
  - `"job.list"`, „Aufträge auflisten“, `{"state": "string"}` → `success({"jobs": queue.list(state)})`
- Werte mit ausdrücklichem Typ lesen (`var kind: String = str(args["kind"])`, `var params: Dictionary = args["params"]`).

## Tests
`tests/test_job_commands.gd`, in `setup()` `registry = CommandRegistry.new()`, `queue = JobQueue.new()`, `JobCommands.register_all(registry, queue)`:
- `test_anlegen`: `execute("job.submit", {"kind": "export", "params": {"ziel": "a.exe"}})` ok, `data["id"]` „j1“
- `test_status`: anlegen, `job.status` „j1“ → `data["state"]` „queued“; `job.status` „j9“ → „not_found“
- `test_abbrechen`: anlegen, `job.cancel` „j1“ ok, danach `job.status` → `data["state"]` „cancelled“; zweites `job.cancel` → „invalid_argument“
- `test_liste`: zwei anlegen, „j1“ abbrechen; `job.list` mit `{"state": "queued"}` → `data["jobs"].size()` 1, mit `{"state": ""}` → 2

Review (19.10.2026): gemergt, nachgebessert: Block-Kommentar ersetzt.
