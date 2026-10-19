---
id: T-0391
title: JobQueue – Aufträge mit Kennung, Fortschritt, Ergebnis und Abbruch
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich: Laufzeit, CLI, Editor, Export“ (Lastenheft Muss 7 „Auftragskennungen, Fortschritt, Ergebnisse“, Muss 11, Abnahmekriterium 14): lange Arbeiten wie Export oder Testlauf laufen als Aufträge, die GUI, CLI, Agenten und der Hub gleich beobachten und abbrechen können. Reine Logik, ohne Threads.

## Dateien
- `core/job_queue.gd` – neu, Klasse `JobQueue`
- `tests/test_job_queue.gd` – neu

## Akzeptanzkriterien
`class_name JobQueue`, `extends RefCounted`. Ergebnisse sind `CommandResult` (`core/command_result.gd`).
- Zustände als Konstanten: `const QUEUED := "queued"`, `const RUNNING := "running"`, `const DONE := "done"`, `const FAILED := "failed"`, `const CANCELLED := "cancelled"`
- `var jobs: Dictionary = {}` – Kennung → `{"id": String, "kind": String, "params": Dictionary, "state": String, "progress": float, "message": String, "result": Dictionary, "error": String}`
- `var order: Array[String] = []`, `var next_id := 1`
- `func submit(kind: String, params: Dictionary) -> String`: Kennung `"j%d" % next_id`, dann `next_id += 1`; Zustand `QUEUED`, `progress` 0.0, `message` „“, `result` `{}`, `error` „“; `params` mit `duplicate(true)` kopieren
- `func get_job(id: String) -> Dictionary`: tiefe Kopie oder `{}`
- `func next_queued() -> String`: Kennung des ältesten Auftrags im Zustand `QUEUED`, sonst „“
- `func start(id: String) -> bool`: nur aus `QUEUED` → `RUNNING`, sonst `false`
- `func report(id: String, progress: float, message: String) -> bool`: nur bei `RUNNING`; `progress` mit `clampf(progress, 0.0, 1.0)` speichern
- `func finish(id: String, result: Dictionary) -> bool`: nur bei `RUNNING` → `DONE`, `progress` 1.0, `result` kopieren
- `func fail(id: String, error: String) -> bool`: nur bei `RUNNING` → `FAILED`, `error` setzen
- `func cancel(id: String) -> CommandResult`:
  - unbekannt → `NOT_FOUND`, `"Auftrag %s gibt es nicht"`
  - Zustand `DONE`, `FAILED` oder `CANCELLED` → `INVALID_ARGUMENT`, `"Auftrag %s ist schon beendet"`
  - sonst Zustand `CANCELLED`, `success({"id": id})`
- `func is_cancelled(id: String) -> bool` (für den ausführenden Code, der zwischendurch nachfragt)
- `func list(state_filter: String = "") -> Array[Dictionary]`: Kopien in Reihenfolge von `order`, bei nicht leerem Filter nur Aufträge in diesem Zustand

## Tests
`tests/test_job_queue.gd`, in `setup()` `queue = JobQueue.new()`:
- `test_kennungen`: zwei Aufträge → „j1“, „j2“; `get_job("j1")["state"]` „queued“; `get_job("j9")` leer
- `test_ablauf`: `submit("export", {"ziel": "a"})`, `start` wahr, `report(id, 0.5, "Halbzeit")` wahr → `progress` 0.5, `message` „Halbzeit“; `finish(id, {"datei": "x.exe"})` → `state` „done“, `progress` 1.0, `result["datei"]` „x.exe“
- `test_fortschritt_begrenzt`: laufender Auftrag, `report(id, 1.7, "")` → `progress` 1.0; `report(id, -1.0, "")` → 0.0
- `test_falsche_reihenfolge`: `report` und `finish` an einem `queued`-Auftrag → falsch; `start` zweimal → beim zweiten Mal falsch
- `test_abbruch`: laufender Auftrag, `cancel(id)` ok → `is_cancelled(id)` wahr, `state` „cancelled“; erneutes `cancel(id)` → Code „invalid_argument“, Meldung „Auftrag j1 ist schon beendet“; `cancel("j9")` → „not_found“
- `test_fehler`: `fail(id, "Vorlage fehlt")` an laufendem Auftrag → `state` „failed“, `error` „Vorlage fehlt“
- `test_warteschlange`: drei Aufträge, den ersten starten → `next_queued()` „j2“; `list("queued").size()` 2; `list().size()` 3
- `test_kopie`: `get_job(id)["params"]["ziel"] = "b"` ändert `get_job(id)["params"]["ziel"]` nicht
