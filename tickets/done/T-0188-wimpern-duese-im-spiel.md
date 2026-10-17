---
id: T-0188
title: Wimpern und Düse der Spielerzelle bewegen sich
project: zellenphase
priority: 3
after: T-0186, T-0187
---
## Ziel
Die Spielerzelle zeichnet Wimpern als schlagende Härchen und lässt die Düse pulsieren.

## Dateien
- `scripts/player_cell.gd`
- `tests/test_player_cell.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
In `scripts/player_cell.gd`:
- Neue Funktionen direkt nach der Funktion `flagellum_points(...)`:
```gdscript
## Wimpern als Linienzüge in Pixeln relativ zur Zellmitte.
func cilia_lines(part: Dictionary) -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	for line in PartAnimation.cilia(time):
		out.append(PartLooks.place(line, part, radius))
	return out


## Umriss der Düse in Pixeln relativ zur Zellmitte; pulsiert im Takt.
func jet_points(part: Dictionary) -> PackedVector2Array:
	var s := PartAnimation.jet_scale(time)
	var pts := PackedVector2Array()
	for p in PartLooks.shape("duese"):
		pts.append(p * s)
	return PartLooks.place(pts, part, radius)
```
- In `_draw()` in der ersten Schleife (Antriebe) den Teil
```gdscript
			else:
				draw_colored_polygon(PartLooks.placed(part, radius), PartLooks.color(part["id"]))
```
  ersetzen durch
```gdscript
			elif part["id"] == "wimpern":
				for line in cilia_lines(part):
					draw_polyline(line, PartLooks.color(part["id"]), maxf(1.0, radius * 0.05))
			elif part["id"] == "duese":
				draw_colored_polygon(jet_points(part), PartLooks.color(part["id"]))
			else:
				draw_colored_polygon(PartLooks.placed(part, radius), PartLooks.color(part["id"]))
```
- Sonst nichts ändern.

## Tests
In `tests/test_player_cell.gd` anhängen:
- `test_wimpern_linien`: `var part := {"id": "wimpern", "pos": Vector2(-1, 0), "angle": 0.0}`, `var lines := cell.cilia_lines(part)` → `lines.size()` ist 5; `lines[0][0].is_equal_approx(Vector2(-cell.radius, -0.25 * cell.radius))` wahr
- `test_duese_pulsiert`: `var part := {"id": "duese", "pos": Vector2(-1, 0), "angle": 0.0}`, `var a := cell.jet_points(part)[1]`, `cell.drive(0.1, Vector2.ZERO)`, `var b := cell.jet_points(part)[1]` → `cell.jet_points(part).size()` ist 4; `a.is_equal_approx(b)` falsch

Review (17.10.2026): gemergt.
