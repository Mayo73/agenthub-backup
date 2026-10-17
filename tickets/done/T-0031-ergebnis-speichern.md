---
id: T-0031
title: Rennergebnis in der Bestenliste speichern
project: drift
priority: 3
after: T-0030
---
## Ziel
Ist ein Rennen zu Ende (3 Runden), trägt `main.gd` Gesamtzeit und Punkte für die gefahrene Strecke in die Bestenliste ein und speichert sie.

## Dateien
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Variablen in `main.gd`: `var highscore_path := HighscoreTable.DEFAULT_PATH` und `var last_record := {}`
- Neue Funktion:
  ```gdscript
  ## Trägt das fertige Rennen in die Bestenliste ein und merkt sich, was neu ist.
  func record_result() -> void:
  	var table := HighscoreTable.load_from(highscore_path)
  	last_record = table.submit(track.track_id, race.race_time, scorer.total)
  	table.save(highscore_path)
  ```
- In `_on_lap_completed` direkt **nach** `race.on_lap(time)`:
  ```gdscript
  	if race.phase == RaceState.Phase.FINISHED:
  		record_result()
  ```
- In `restart()` zusätzlich `last_record = {}`
- Sonst nichts an `main.gd` ändern.

## Tests
In `tests/test_main_wiring.gd` neue Methode `test_ergebnis_wird_gespeichert` anhängen:
- `var path := "user://test_main_bestenliste.json"`; falls die Datei existiert (`FileAccess.file_exists(path)`), löschen mit `DirAccess.remove_absolute(ProjectSettings.globalize_path(path))`
- `main.highscore_path = path`, `main.race.race_time = 90.0`, `main.record_result()`
- `main.last_record["new_time"]` ist wahr
- `HighscoreTable.load_from(path).best_time(main.track.track_id)` ist 90.0
- `main.restart()` → `main.last_record.is_empty()` ist wahr
- am Ende die Datei wieder löschen

Review (16.10.2026): gemergt.
