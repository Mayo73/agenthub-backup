---
id: T-0024
title: Strecke aus dem Katalog laden
project: drift
priority: 3
after: T-0023
---
## Ziel
Der Strecken-Node `scripts/track.gd` soll jede Strecke aus `TrackCatalog` (T-0023) laden können. Beim Start lädt er wie bisher den Hafenring, jetzt aber aus dem Katalog.

## Dateien
- `scripts/track.gd`
- `tests/test_track_loading.gd`: neu

## Akzeptanzkriterien
- Neue Variable `var track_id := ""` (unter `var path: TrackPath`)
- Neue Funktion:
  ```gdscript
  ## Lädt eine Strecke aus dem TrackCatalog. Unbekannte IDs werden ignoriert.
  func load_track(id: String) -> void:
  	if not TrackCatalog.has_track(id):
  		return
  	track_id = id
  	control_points = TrackCatalog.points_of(id)
  	width = TrackCatalog.width_of(id)
  	path = TrackPath.new(TrackPath.smooth_closed(control_points, SMOOTH_STEPS), width)
  	queue_redraw()
  ```
- `_ready()` wird zu: `load_track(TrackCatalog.DEFAULT_ID)` (statt die Strecke selbst zu bauen). `_draw()` und alles andere bleibt unverändert.

## Tests
Neue Datei `tests/test_track_loading.gd` mit `extends "res://tests/base_test.gd"`. Den Node jeweils mit `var track: Node2D = preload("res://scripts/track.gd").new()` anlegen und am Ende `track.free()`.
- `test_laedt_strecke`: `track.load_track("hafen")` → `track.track_id` ist `"hafen"`, `track.path != null`, `track.path.width` ist 280.0, `track.path.length > 1000.0`
- `test_unbekannte_strecke_ignoriert`: `track.load_track("hafen")`, dann `track.load_track("gibtsnicht")` → `track.track_id` ist weiterhin `"hafen"`
- `test_beim_start_geladen`: `var main: Node = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)` → `main.get_node("World/Track").track_id` ist `TrackCatalog.DEFAULT_ID`; danach `main.free()` (hier nicht `track.free()`; den oben angelegten `track` trotzdem freigeben)

Review (16.10.2026): gemergt.
