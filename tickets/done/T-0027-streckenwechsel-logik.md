---
id: T-0027
title: Strecke wechseln in GameSettings
project: drift
priority: 2
---
## Ziel
Das Hauptmenü soll gleich zwischen den drei Strecken umschalten können. Dafür bekommt `GameSettings` zwei Funktionen, die zur nächsten bzw. vorherigen Strecke im `TrackCatalog` wechseln (am Ende geht es wieder von vorn los).

## Dateien
- `scripts/game_settings.gd`: zwei neue statische Funktionen und eine Hilfsfunktion
- `tests/test_game_settings.gd`: neu

## Akzeptanzkriterien
- `static var track_id` bleibt, wie es ist.
- Neue Hilfsfunktion:
  ```gdscript
  ## Nächster (dir = 1) oder vorheriger (dir = -1) Eintrag, im Kreis. Unbekannt → erster Eintrag.
  static func step_id(ids: Array[String], current: String, dir: int) -> String:
  	if ids.is_empty():
  		return current
  	var i := ids.find(current)
  	if i < 0:
  		return ids[0]
  	return ids[(i + dir + ids.size()) % ids.size()]
  ```
- `static func next_track() -> void:` setzt `track_id = step_id(TrackCatalog.ids(), track_id, 1)`
- `static func previous_track() -> void:` setzt `track_id = step_id(TrackCatalog.ids(), track_id, -1)`
- Die Reihenfolge in `TrackCatalog.ids()` ist `"hafen"`, `"altstadt"`, `"kurvenring"`.

## Tests
Neue Datei `tests/test_game_settings.gd` mit `extends "res://tests/base_test.gd"`. In `setup()` und in `teardown()` jeweils `GameSettings.track_id = TrackCatalog.DEFAULT_ID` (der Wert ist statisch und gilt für alle Tests).
- `test_naechste_strecke`: `GameSettings.next_track()` → `GameSettings.track_id` ist `"altstadt"`; noch einmal → `"kurvenring"`; noch einmal → `"hafen"`
- `test_vorherige_strecke`: `GameSettings.previous_track()` → `"kurvenring"`
- `test_step_id_unbekannt`: `var ids: Array[String] = ["a", "b"]`; `GameSettings.step_id(ids, "x", 1)` ist `"a"`; `GameSettings.step_id(ids, "b", 1)` ist `"a"`; `GameSettings.step_id(ids, "a", -1)` ist `"b"`

Review (16.10.2026): gemergt.
