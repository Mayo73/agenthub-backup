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
