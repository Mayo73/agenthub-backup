---
id: T-0193
title: Zellkörper mit Schatten und Glanzlicht zeichnen
project: zellenphase
priority: 3
after: T-0192
---
## Ziel
`CellPainter.draw_cell` zeichnet unter jedem Zellkörper einen Schatten und darauf ein Glanzlicht. Weil alle Zellen (Spieler, KI, Partner, Editor) über `draw_cell` gezeichnet werden, wirken danach alle räumlicher.

## Dateien
- `scripts/cell_painter.gd`
- `tests/test_cell_painter.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
In `scripts/cell_painter.gd`:
- Neue Funktion direkt über `static func draw_cell(...)`:
```gdscript
## Umriss des Schattens: die Punkte des Körpers, um den Schattenversatz verschoben.
static func shadow_points(points: PackedVector2Array, radius: float, rotation: float) -> PackedVector2Array:
	var off := CellShading.shadow_offset(radius, rotation)
	var out := PackedVector2Array()
	for p in points:
		out.append(p + off)
	return out


```
- In `draw_cell(...)` direkt vor der Zeile `canvas.draw_colored_polygon(points, look.color, uv, TEXTURE)`:
```gdscript
	var rot := canvas.get_global_transform().get_rotation()
	canvas.draw_colored_polygon(shadow_points(points, radius, rot), CellShading.SHADOW_COLOR)
```
- In `draw_cell(...)` direkt vor der Zeile `points.append(points[0])`:
```gdscript
	canvas.draw_circle(center + CellShading.highlight_center(radius, rot), CellShading.highlight_radius(radius), CellShading.highlight_color(look))
```
- Sonst nichts ändern.

## Tests
In `tests/test_cell_painter.gd` anhängen:
- `test_schatten`: `var s := CellPainter.shadow_points(PackedVector2Array([Vector2(0, 0), Vector2(10, 0)]), 10.0, 0.0)` → `s.size()` ist 2; `s[0].is_equal_approx(Vector2(1.2, 1.6))` wahr; `s[1].is_equal_approx(Vector2(11.2, 1.6))` wahr
- `test_schatten_gedreht`: `var s := CellPainter.shadow_points(PackedVector2Array([Vector2(0, 0)]), 10.0, PI / 2.0)` → `s[0].is_equal_approx(Vector2(1.6, -1.2))` wahr

Review (17.10.2026): gemergt, nachgebessert: Zeile zum Zeichnen des Zellkörpers wiederhergestellt (der Agent hatte sie ersetzt statt ergänzt).
