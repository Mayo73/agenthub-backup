---
id: T-0066
title: Reifenstapel und Bäume an der Strecke zeichnen
project: drift
priority: 3
after: T-0065
---
## Ziel
Die Strecke zeichnet die Deko aus `TrackDecor`: Reifenstapel als drei dunkle Ringe, Bäume als grüne Kreise.

## Dateien
- `scripts/track.gd`
- `tests/test_track_loading.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Variable in `track.gd` (unter `var track_id`): `var decor: Array[Dictionary] = []`
- In `load_track()` direkt nach der Zeile `path = TrackPath.new(…)`: `decor = TrackDecor.build(path)`
- In `_draw()` als letzte Zeile (nach `_draw_start_line()`): `_draw_decor()`
- Neue Funktion am Ende der Datei:
```gdscript


## Reifenstapel (drei dunkle Ringe nebeneinander) und Bäume (grüne Kreise mit hellerer Krone).
func _draw_decor() -> void:
	for item in decor:
		var p: Vector2 = item["position"]
		if item["kind"] == TrackDecor.Kind.TIRES:
			for k in 3:
				var c := p + Vector2(k * 22.0 - 22.0, 0.0)
				draw_circle(c, 12.0, Color(0.08, 0.08, 0.09))
				draw_circle(c, 5.0, Color(0.3, 0.3, 0.32))
		else:
			draw_circle(p, 46.0, Color(0.1, 0.28, 0.12))
			draw_circle(p + Vector2(-8, -8), 30.0, Color(0.16, 0.42, 0.18))
```
- Sonst nichts an `track.gd` ändern.

## Tests
In `tests/test_track_loading.gd` neue Methode `test_deko_geladen`:
- `var track: Node2D = preload("res://scripts/track.gd").new()`, `track.load_track("altstadt")`
- `track.decor.size() > 0`; es gibt mindestens einen Eintrag mit `item["kind"] == TrackDecor.Kind.TIRES` und einen mit `item["kind"] == TrackDecor.Kind.TREE`
- `track.has_method("_draw_decor")` ist wahr
- am Ende `track.free()`

Review (16.10.2026): gemergt.
