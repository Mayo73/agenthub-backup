---
id: T-0591
title: Abnahmetest Kriterium 14 – Auftrag mit Fortschritt, Ergebnis und Abbruch
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Abnahme“, Kriterium 14: Ein Auftrag läuft mit Fortschritt bis zum Ergebnis samt Artefaktpfad, ein zweiter lässt sich abbrechen, die Engine läuft danach unabhängig weiter. Nur ein neuer Test, keine Änderung am Kern.

## Dateien
- `tests/test_abnahme_auftrag.gd` – neu

## Akzeptanzkriterien
Vorher `core/job_queue.gd` und `core/sim_clock.gd` lesen. In `setup()`: `q = JobQueue.new()`.

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs. Werte aus Dictionaries mit Typ lesen (`var j: Dictionary = q.get_job(id)`).

## Tests
`tests/test_abnahme_auftrag.gd`:
- `test_ergebnis`: `var id: String = q.submit("export", {"ziel": "user://export/kisten.exe"})` ist „j1“; `start(id)` wahr; `report(id, 0.5, "Export läuft")` wahr; `q.get_job(id)` hat `progress` 0.5 und `message` „Export läuft“; `finish(id, {"artifact": "user://export/kisten.exe"})` wahr; danach hat der Auftrag `state` „done“, `progress` 1.0 und `result["artifact"]` „user://export/kisten.exe“
- `test_fehler`: Auftrag einreichen und starten, `fail(id, "Vorlage fehlt")` → `state` „failed“, `error` „Vorlage fehlt“
- `test_abbrechen`: zwei Aufträge `a` und `b`; `start(a)`; `cancel(b).code` „ok“, `is_cancelled(b)` wahr, `start(b)` falsch, `next_queued()` ist ""; `finish(a, {})` wahr
- `test_beendet_nicht_abbrechbar`: gestarteter und mit `finish` beendeter Auftrag → `cancel(id).code` „invalid_argument“
- `test_engine_unabhaengig`: nach dem Abbruch eines Auftrags: `var clock := SimClock.new()`, `clock.step(3)` ist 3 und `clock.step_count` ist 3
