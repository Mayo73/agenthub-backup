---
id: T-0029
title: Bestenliste – Logik (HighscoreTable)
project: drift
priority: 3
---
## Ziel
Eine Klasse `HighscoreTable` merkt sich je Strecke die beste Gesamtzeit eines Rennens und die höchste Punktzahl. Das Speichern auf die Festplatte folgt im nächsten Ticket.

## Dateien
- `scripts/highscore_table.gd`: neu, beginnt mit `class_name HighscoreTable` und `extends RefCounted`
- `tests/test_highscore_table.gd`: neu

## Akzeptanzkriterien
- `var entries := {}`: Schlüssel = Strecken-ID, Wert = `{"time": float, "points": int}`
- `func best_time(track_id: String) -> float`: gespeicherte Zeit, `-1.0`, wenn es keinen Eintrag gibt
- `func best_points(track_id: String) -> int`: gespeicherte Punkte als `int(...)`, `0`, wenn es keinen Eintrag gibt
- `func submit(track_id: String, time: float, points: int) -> Dictionary`:
  - `new_time` ist wahr, wenn `time > 0.0` und (`best_time(track_id) < 0.0` oder `time < best_time(track_id)`)
  - `new_points` ist wahr, wenn `points > best_points(track_id)`
  - legt den Eintrag bei Bedarf an (`{"time": -1.0, "points": 0}`) und übernimmt die neuen Bestwerte
  - gibt `{"new_time": new_time, "new_points": new_points}` zurück

## Tests
Neue Datei `tests/test_highscore_table.gd` mit `extends "res://tests/base_test.gd"`, `var table: HighscoreTable`, in `setup()` `table = HighscoreTable.new()`:
- `test_leer`: `table.best_time("hafen")` ist -1.0, `table.best_points("hafen")` ist 0
- `test_erster_eintrag`: `var r := table.submit("hafen", 95.5, 800)` → `r["new_time"]` wahr, `r["new_points"]` wahr, `best_time("hafen")` ist 95.5, `best_points("hafen")` ist 800
- `test_schlechter_bleibt`: `submit("hafen", 95.5, 800)`, dann `var r := table.submit("hafen", 99.0, 700)` → beide falsch, Bestwerte unverändert (95.5 und 800)
- `test_nur_punkte_besser`: `submit("hafen", 95.5, 800)`, dann `var r := table.submit("hafen", 97.0, 900)` → `r["new_time"]` falsch, `r["new_points"]` wahr, `best_time("hafen")` 95.5, `best_points("hafen")` 900
- `test_strecken_getrennt`: `submit("hafen", 95.5, 800)` → `best_time("altstadt")` ist -1.0

Review (16.10.2026): gemergt.
