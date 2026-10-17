---
id: T-0030
title: Bestenliste speichern und laden
project: drift
priority: 3
after: T-0029
---
## Ziel
Die Bestenliste soll einen Neustart des Spiels überleben. `HighscoreTable` speichert sich als JSON-Datei im Benutzerordner und kann sich daraus wieder laden.

## Dateien
- `scripts/highscore_table.gd`
- `tests/test_highscore_table.gd`

## Akzeptanzkriterien
- `const DEFAULT_PATH := "user://bestenliste.json"`
- `func save(path: String = DEFAULT_PATH) -> bool`: `var file := FileAccess.open(path, FileAccess.WRITE)`; ist `file == null`, `false` zurückgeben; sonst `file.store_string(JSON.stringify(entries))`, `file.close()` und `true`
- `static func load_from(path: String = DEFAULT_PATH) -> HighscoreTable`:
  - legt eine neue Tabelle an (`var table := HighscoreTable.new()`)
  - gibt sie leer zurück, wenn `not FileAccess.file_exists(path)`
  - liest den Text mit `FileAccess.get_file_as_string(path)` und parst ihn mit `JSON.parse_string(text)`; ist das Ergebnis kein `Dictionary`, die leere Tabelle zurückgeben
  - übernimmt jeden Eintrag `e`, der ein `Dictionary` ist, als `{"time": float(e.get("time", -1.0)), "points": int(e.get("points", 0))}` in `table.entries`

## Tests
In `tests/test_highscore_table.gd` anhängen. Oben `const TEST_PATH := "user://test_bestenliste.json"`. Neue Funktion `teardown()`, die die Testdatei löscht:
```gdscript
func teardown() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
```
- `test_speichern_und_laden`: `table.submit("hafen", 95.5, 800)`, `table.submit("altstadt", 120.25, 1500)`, `check(table.save(TEST_PATH), "speichern klappt")`; `var loaded := HighscoreTable.load_from(TEST_PATH)` → `loaded.best_time("hafen")` ist 95.5, `loaded.best_points("hafen")` ist 800, `loaded.best_time("altstadt")` ist 120.25, `loaded.best_points("altstadt")` ist 1500
- `test_fehlende_datei`: `HighscoreTable.load_from("user://gibt_es_nicht.json").best_time("hafen")` ist -1.0
- `test_kaputte_datei`: `var f := FileAccess.open(TEST_PATH, FileAccess.WRITE)`, `f.store_string("kein json")`, `f.close()` → `HighscoreTable.load_from(TEST_PATH).best_points("hafen")` ist 0

Review (16.10.2026): gemergt, nachgebessert: load_from übersprang fehlerhafte Einträge nicht (typisierte Variable), unnötige null-Prüfung entfernt.
