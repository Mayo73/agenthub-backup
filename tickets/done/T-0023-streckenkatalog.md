---
id: T-0023
title: Streckenkatalog (TrackCatalog)
project: drift
priority: 3
---
## Ziel
Grundlage für mehrere Strecken: Eine Klasse `TrackCatalog` hält die Daten aller Strecken (Name, Breite, Kontrollpunkte der Mittellinie). Vorerst steht nur die bisherige Strecke darin; die weiteren Strecken trägt Claude später ein.

## Dateien
- `scripts/track_catalog.gd`: neu, beginnt mit `class_name TrackCatalog` und `extends RefCounted`
- `tests/test_track_catalog.gd`: neu

## Akzeptanzkriterien
- `const DEFAULT_ID := "hafen"`
- Konstante mit genau diesen Daten (die Punkte sind die bisherigen aus `scripts/track.gd`):
  ```gdscript
  const TRACKS := {
  	"hafen": {
  		"name": "Hafenring",
  		"width": 280.0,
  		"points": [
  			Vector2(0, 0), Vector2(1400, 0), Vector2(2000, 200), Vector2(2300, 700),
  			Vector2(2150, 1300), Vector2(1650, 1550), Vector2(1150, 1350), Vector2(750, 1600),
  			Vector2(200, 1650), Vector2(-450, 1400), Vector2(-700, 850), Vector2(-600, 350),
  			Vector2(-350, 80),
  		],
  	},
  }
  ```
- `static func ids() -> Array[String]`: alle Schlüssel von `TRACKS` als Strings, in der Reihenfolge von `TRACKS`
- `static func has_track(id: String) -> bool`
- `static func name_of(id: String) -> String`: `""`, wenn unbekannt
- `static func width_of(id: String) -> float`: `280.0`, wenn unbekannt
- `static func points_of(id: String) -> PackedVector2Array`: die Punkte als `PackedVector2Array`, leer wenn unbekannt
- `scripts/track.gd` noch **nicht** ändern.

## Tests
Neue Datei `tests/test_track_catalog.gd` mit `extends "res://tests/base_test.gd"`:
- `test_standardstrecke`: `TrackCatalog.has_track(TrackCatalog.DEFAULT_ID)` ist wahr, `TrackCatalog.ids()` enthält `"hafen"`
- `test_hafenring`: `name_of("hafen")` ist `"Hafenring"`, `width_of("hafen")` ist 280.0, `points_of("hafen").size()` ist 13, `points_of("hafen")[1]` ist `Vector2(1400, 0)`
- `test_unbekannt`: `has_track("gibtsnicht")` falsch, `name_of("gibtsnicht")` ist `""`, `points_of("gibtsnicht").size()` ist 0, `width_of("gibtsnicht")` ist 280.0
- `test_jede_strecke_hat_genug_punkte`: für jede `id` in `ids()`: `points_of(id).size() >= 4` und `name_of(id) != ""`

Review (16.10.2026): gemergt.
