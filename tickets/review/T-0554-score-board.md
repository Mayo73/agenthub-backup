---
id: T-0554
title: ScoreBoard – Bestenliste für die Referenzspiele
project: hub-engine
priority: 4
---
## Ziel
Muss 1 „spielbare 2D- und 3D-Beispiele“: Die Referenzspiele bekommen eine Bestenliste mit begrenzter Länge, die sich als JSON speichern lässt.

## Dateien
- `core/score_board.gd` – neu, Klasse `ScoreBoard`
- `tests/test_score_board.gd` – neu

## Akzeptanzkriterien
`class_name ScoreBoard`, `extends RefCounted`.
- `var max_entries := 10`, `var entries: Array[Dictionary] = []` (je `{"name": String, "score": int}`, beste zuerst)
- `func qualifies(score: int) -> bool`: weniger als `max_entries` Einträge oder `score` größer als der letzte
- `func add(name: String, score: int) -> int`: kommt nicht in die Liste → 0; sonst hinter allen Einträgen mit gleichem oder höherem Wert einfügen (bei Gleichstand bleibt der ältere vorne), auf `max_entries` kürzen, Platz (ab 1) zurückgeben
- `func best() -> int`: höchster Wert, leer 0
- `func lines() -> Array[String]`: je Eintrag `"%d. %s – %d" % [platz, name, score]`
- `func to_dict() -> Dictionary` (`max_entries`, `entries`) und `static func from_dict(d: Dictionary) -> ScoreBoard` (Zahlen mit `int(...)`)

Hinweis Typen: Werte aus Dictionaries immer mit Typ lesen (`var s: int = int(e["score"])`).

## Tests
`tests/test_score_board.gd`:
- `test_sortiert`: `add("a", 100)` 1, `add("b", 300)` 1, `add("c", 200)` 2 → Namen in `entries` sind „b“, „c“, „a“; `best()` 300
- `test_gleich`: `add("x", 100)`, `add("y", 100)` → zweiter Aufruf gibt 2, `entries[0]["name"]` „x“
- `test_voll`: `max_entries = 3`, Werte 300, 200, 100 → `add("d", 50)` 0, `entries.size()` 3; `add("e", 150)` 3, `entries.size()` 3, `entries[2]["score"]` 150
- `test_zeilen`: nach `test_sortiert`-Daten ist `lines()[0]` „1. b – 300“
- `test_speichern`: `var d: Dictionary = JSON.parse_string(JSON.stringify(board.to_dict()))` → `ScoreBoard.from_dict(d)` hat `best()` 300 und 3 Einträge
