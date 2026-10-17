---
id: T-0166
title: Zellkörper mit Textur, Muster und Membranrand zeichnen (CellPainter)
project: zellenphase
priority: 2
after: T-0164, T-0165, A-0012
---
## Ziel
Eine gemeinsame Zeichenfunktion für alle Zellen (Spieler, KI-Zellen, Partner, Editor): Körper mit der eingefärbten Higgsfield-Textur `assets/cells/zellkoerper.png` (hell, wird mit `look.color` eingefärbt), darauf das Muster und ein hellerer Membranrand. Der Einbau folgt in eigenen Tickets.

## Dateien
- `scripts/cell_painter.gd`: neu
- `tests/test_cell_painter.gd`: neu

## Akzeptanzkriterien
`scripts/cell_painter.gd` genau so:
```gdscript
class_name CellPainter
extends RefCounted
## Zeichnet einen Zellkörper: eingefärbte Textur, Muster und Membranrand. Nur aus _draw() aufrufen.

const TEXTURE: Texture2D = preload("res://assets/cells/zellkoerper.png")
const PATTERN_DARK := 0.35
const RIM_LIGHT := 0.35


static func pattern_color(look: CellLook) -> Color:
	var c := look.color.darkened(PATTERN_DARK)
	c.a = 0.8
	return c


static func rim_color(look: CellLook) -> Color:
	var c := look.color.lightened(RIM_LIGHT)
	c.a = 0.9
	return c


static func rim_width(radius: float) -> float:
	return maxf(1.0, radius * 0.08)


static func draw_cell(canvas: CanvasItem, center: Vector2, look: CellLook, radius: float, time: float) -> void:
	var outline := CellBody.wobble(look, radius, time)
	var uv := CellBody.uvs(outline, CellBody.half_size(look, radius))
	var points := PackedVector2Array()
	for p in outline:
		points.append(center + p)
	canvas.draw_colored_polygon(points, look.color, uv, TEXTURE)
	for mark: Dictionary in CellPattern.marks(look.pattern):
		var mpos: Vector2 = mark["pos"]
		var pos := center + CellPattern.to_local(mpos, radius, look)
		var size: float = mark["size"] * radius
		if mark["stripe"]:
			var half: float = CellPattern.stripe_half(mpos.x) * radius / look.stretch
			canvas.draw_line(pos - Vector2(0, half), pos + Vector2(0, half), pattern_color(look), size * 2.0)
		else:
			canvas.draw_circle(pos, size, pattern_color(look))
	points.append(points[0])
	canvas.draw_polyline(points, rim_color(look), rim_width(radius))
```

## Tests
`tests/test_cell_painter.gd` mit `extends "res://tests/base_test.gd"`:
- `test_textur`: `CellPainter.TEXTURE != null` wahr; `CellPainter.TEXTURE.get_width() >= 500` wahr
- `test_musterfarbe`: `var l := CellLook.new()`, `l.color = Color(1, 1, 1)` → `CellPainter.pattern_color(l).is_equal_approx(Color(0.65, 0.65, 0.65, 0.8))` wahr
- `test_randfarbe`: `var l := CellLook.new()`, `l.color = Color(0, 0, 0)` → `CellPainter.rim_color(l).is_equal_approx(Color(0.35, 0.35, 0.35, 0.9))` wahr
- `test_randbreite`: `CellPainter.rim_width(5.0)` ist 1.0; `CellPainter.rim_width(50.0)` ist 4.0

Review (16.10.2026): gemergt.
