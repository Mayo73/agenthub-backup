---
id: T-0593
title: LogBuffer – Laufzeitprotokoll mit Ebenen und fester Länge
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich“ (Abnahmekriterium 13: Testlauf liefert Log): Laufzeitmeldungen mit Schritt und Ebene sammeln, nach Mindest-Ebene filtern und als Textzeilen ausgeben.

## Dateien
- `core/log_buffer.gd` – neu, Klasse `LogBuffer`
- `tests/test_log_buffer.gd` – neu

## Akzeptanzkriterien
`class_name LogBuffer`, `extends RefCounted`.
- `const LEVELS := ["debug", "info", "warn", "error"]`
- `var capacity := 100`, `var entries: Array[Dictionary] = []` (je `{"step": int, "level": String, "text": String}`)
- `func _init(max_entries: int = 100) -> void`: `capacity = max_entries`
- `func add(step: int, level: String, text: String) -> bool`: Ebene nicht in `LEVELS` → `false`; sonst anhängen, bei mehr als `capacity` Einträgen den ältesten entfernen (`pop_front()`), `true`
- `func filter(min_level: String) -> Array[Dictionary]`: alle Einträge, deren Ebene in `LEVELS` mindestens so weit hinten steht wie `min_level`, in Reihenfolge; unbekannte Ebene → `[]`
- `func count(level: String) -> int`: Anzahl mit genau dieser Ebene
- `func lines() -> Array[String]`: je Eintrag `"[%d] %s: %s" % [step, level.to_upper(), text]`
- `func clear() -> void`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs. Werte aus Dictionaries mit Typ lesen (`var lvl: String = e["level"]`).

## Tests
`tests/test_log_buffer.gd`:
- `test_filtern`: `add(1, "info", "Start")`, `add(2, "debug", "Detail")`, `add(3, "error", "Absturz")` → `filter("info").size()` 2, `filter("error").size()` 1, `filter("debug").size()` 3, `filter("laut")` leer
- `test_zaehlen`: nach denselben Einträgen ist `count("error")` 1 und `count("warn")` 0; `add(4, "laut", "x")` ist falsch und ändert nichts (`entries.size()` 3)
- `test_laenge`: `LogBuffer.new(2)`, drei Einträge mit den Schritten 1, 2, 3 → `entries.size()` 2, `entries[0]["step"]` 2
- `test_zeilen`: `add(1, "info", "Start")` → `lines()[0]` ist „[1] INFO: Start“; nach `clear()` ist `lines()` leer
