---
id: T-0491
title: HubReport – Engine-Aufträge als Bericht für Hub-Tickets
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „KI, Agenten und Hub“ (Muss 11: „Der Agent-Hub-Adapter kann Engine-Aufträge starten, beobachten, abbrechen und Ergebnisse an Hub-Tickets/Materialien zurückliefern“): Ein Auftrag aus `JobQueue` wird als Markdown-Bericht und als kurze Statuszeile ausgegeben.

## Dateien
- `core/hub_report.gd` – neu, Klasse `HubReport`
- `tests/test_hub_report.gd` – neu

## Akzeptanzkriterien
`class_name HubReport`, `extends RefCounted`, nur statische Funktionen. Vorher `core/job_queue.gd` lesen (Auftrag als Dictionary mit `id`, `kind`, `params`, `state`, `progress`, `message`, `result`, `error`).
- `const STATE_NAMES := {JobQueue.QUEUED: "wartet", JobQueue.RUNNING: "läuft", JobQueue.DONE: "fertig", JobQueue.FAILED: "fehlgeschlagen", JobQueue.CANCELLED: "abgebrochen"}`
- `static func status_line(job: Dictionary) -> String`: `"%s %s: %s, %d %%" % [id, kind, Zustandsname, int(progress * 100)]`, bei nicht leerer `message` zusätzlich `" – " + message`
- `static func markdown(job: Dictionary) -> String`: Zeilen `"# Auftrag " + id`, Leerzeile, `"- Art: " + kind`, `"- Zustand: " + Zustandsname`, `"- Fortschritt: %d %%"`; bei Fehler `"- Fehler: " + error`; hat `result` Einträge: Leerzeile, `"## Ergebnis"`, dann je Schlüssel (sortiert) `"- schlüssel: wert"`; Zeilen mit `"\n"` verbunden
- `static func files(job: Dictionary) -> Array[String]`: Ist `result["files"]` ein Array, dessen Einträge als Strings, sonst leer (Ergebnisdateien für das Hub-Material)

## Tests
`tests/test_hub_report.gd`, `setup()`: `queue = JobQueue.new()`, `id = queue.submit("export", {"ziel": "windows"})`:
- `test_status`: nach `queue.start(id)` und `queue.report(id, 0.4, "Packe Dateien")` → `status_line(queue.get_job(id))` enthält „export“, „läuft“, „40 %“ und „Packe Dateien“
- `test_bericht_fertig`: `queue.start(id)`, `queue.finish(id, {"files": ["build/spiel.exe"], "dauer": 12})` → `markdown(...)` enthält „# Auftrag “, „- Zustand: fertig“, „## Ergebnis“ und „- dauer: 12“; `files(...)` ist `["build/spiel.exe"]`
- `test_fehler`: `queue.start(id)`, `queue.fail(id, "Vorlage fehlt")` → `markdown(...)` enthält „- Fehler: Vorlage fehlt“, `files(...)` leer

Review (2026-10-21): gemergt, nachgebessert: Zustandsnamen als Konstante STATE_NAMES statt doppelter if-Ketten.
