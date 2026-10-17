---
id: T-0171
title: Geißel der Spielerzelle schlängelt sich
project: zellenphase
priority: 2
after: T-0167, T-0170
---
## Ziel
Die Geißel der Spielerzelle wird als schlängelnde Linie gezeichnet (`PartAnimation.flagellum`) statt als starres Dreieck. Die übrigen Antriebe bleiben wie bisher.

## Dateien
- `scripts/player_cell.gd`
- `tests/test_player_cell.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
In `scripts/player_cell.gd`:
- Neue Funktion direkt über `func _draw()`:
```gdscript
## Linienzug einer Geißel in Pixeln relativ zur Zellmitte, passend zur aktuellen Zeit.
func flagellum_points(part: Dictionary) -> PackedVector2Array:
	return PartAnimation.place_points(PartAnimation.flagellum(time), part, radius)
```
- In `_draw()` in der ersten Schleife (die Antriebe zeichnet) die Zeile `draw_colored_polygon(PartShapes.placed(part, radius), PartShapes.color_of(part["id"]))` ersetzen durch:
```gdscript
			if part["id"] == "geissel":
				draw_polyline(flagellum_points(part), PartShapes.color_of(part["id"]), maxf(1.5, radius * 0.1))
			else:
				draw_colored_polygon(PartShapes.placed(part, radius), PartShapes.color_of(part["id"]))
```
- Sonst nichts ändern.

## Tests
In `tests/test_player_cell.gd` anhängen:
- `test_geissel_punkte`: `var part := {"id": "geissel", "pos": Vector2(-1, 0), "angle": 0.0}` → `cell.flagellum_points(part).size()` ist 8; `cell.flagellum_points(part)[0].is_equal_approx(Vector2(-cell.radius, 0))` wahr
- `test_geissel_bewegt_sich`: `var part := {"id": "geissel", "pos": Vector2(-1, 0), "angle": 0.0}`, `var a := cell.flagellum_points(part)[7]`, `cell.drive(0.1, Vector2.ZERO)`, `var b := cell.flagellum_points(part)[7]` → `a.is_equal_approx(b)` falsch

Review (16.10.2026): gemergt.
