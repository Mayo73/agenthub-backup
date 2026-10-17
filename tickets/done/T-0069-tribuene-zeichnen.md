---
id: T-0069
title: Tribüne an der Startlinie zeichnen
project: drift
priority: 3
after: T-0066, T-0068
---
## Ziel
Die Strecke zeichnet die Tribüne aus `TrackDecor.grandstand()`: eine graue Fläche mit bunten Sitzreihen.

## Dateien
- `scripts/track.gd`
- `tests/test_track_loading.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Variable in `track.gd` (unter `var decor`): `var stand := PackedVector2Array()`
- In `load_track()` direkt nach `decor = TrackDecor.build(path)`: `stand = TrackDecor.grandstand(path)`
- In `_draw_decor()` als **erste** Zeilen:
```gdscript
	if stand.size() == 4:
		draw_colored_polygon(stand, Color(0.45, 0.45, 0.48))
		for row in 3:
			var t0 := 0.15 + row * 0.28
			var t1 := t0 + 0.14
			var a := stand[0].lerp(stand[3], t0)
			var b := stand[1].lerp(stand[2], t0)
			var c := stand[1].lerp(stand[2], t1)
			var d := stand[0].lerp(stand[3], t1)
			draw_colored_polygon(PackedVector2Array([a, b, c, d]), [Color(0.8, 0.2, 0.2), Color(0.2, 0.4, 0.85), Color(0.95, 0.8, 0.2)][row])
```
- Sonst nichts an `track.gd` ändern.

## Tests
In `tests/test_track_loading.gd` neue Methode `test_tribuene_geladen`:
- `var track: Node2D = preload("res://scripts/track.gd").new()`, `track.load_track("kurvenring")`
- `track.stand.size()` ist 4
- für keine Ecke `e` in `track.stand` ist `track.path.is_on_track(e)` wahr
- am Ende `track.free()`

Review (16.10.2026): gemergt.
