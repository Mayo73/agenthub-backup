---
id: T-0076
title: Bäume und Reifenstapel als Bilder zeichnen
project: drift
priority: 5
after: A-0005, A-0006
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Die Strecken-Deko zeigt die neuen Bilder (Medien-Aufträge A-0005 Baum, A-0006 Reifenstapel) statt der einfachen Kreise.

## Dateien
- `scripts/track.gd`
- `tests/test_track_loading.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Konstanten in `track.gd` direkt unter `const START_CELL := 20.0`:
```gdscript
const TREE_TEXTURE := preload("res://assets/decor/tree.png")
const TIRES_TEXTURE := preload("res://assets/decor/tires.png")
const TREE_SIZE := Vector2(92, 96)
const TIRES_SIZE := Vector2(70, 29)
```
- In `_draw_decor()` wird die Schleife `for item in decor:` (der Teil mit den Kreisen) ersetzt durch:
```gdscript
	for item in decor:
		var p: Vector2 = item["position"]
		if item["kind"] == TrackDecor.Kind.TIRES:
			draw_texture_rect(TIRES_TEXTURE, Rect2(p - TIRES_SIZE * 0.5, TIRES_SIZE), false)
		else:
			draw_circle(p + Vector2(8, 8), 40.0, Color(0, 0, 0, 0.25))
			draw_texture_rect(TREE_TEXTURE, Rect2(p - TREE_SIZE * 0.5, TREE_SIZE), false)
```
- Die Tribüne am Anfang von `_draw_decor()` bleibt unverändert. Sonst nichts an `track.gd` ändern.

## Tests
In `tests/test_track_loading.gd` neue Methode `test_deko_bilder`:
- `var track: Node2D = preload("res://scripts/track.gd").new()`
- `track.TREE_TEXTURE.get_width() > 0` und `track.TIRES_TEXTURE.get_width() > 0` sind wahr
- `track.TREE_SIZE` ist `Vector2(92, 96)`
- am Ende `track.free()`

Review (16.10.2026): gemergt.
