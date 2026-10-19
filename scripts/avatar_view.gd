class_name AvatarView
extends Control

## Zeigt den Avatar eines SparProfile als selbst gezeichnetes, illustriertes Porträt:
## Hintergrund im Verlauf der Profilfarbe, Kopf mit Frisur, Hals und Schultern.
## Rund (Listen, Kopfzeilen) oder als Fläche mit abgerundeten Ecken (Profilkarte, `set_fill`).
## Keine externen Bilddateien, alles wird per Code gezeichnet; Frisur, Haar- und Hautfarbe
## folgen fest aus der Profil-ID, sehen also immer gleich aus.

const SKIN := [Color("#F1C7A5"), Color("#E0AC88"), Color("#C68A62"), Color("#8D5A3B"), Color("#5C3A24")]
const HAIR := [Color("#2B1D14"), Color("#121212"), Color("#C9A24A"), Color("#7A3B1E"), Color("#5A4632")]
## Frisuren: kurz, lang, Dutt, sehr kurz
const STYLES := 4

var profile: SparProfile = null
## Füllt die ganze Fläche statt eines Kreises (für die Profilkarte).
var fill := false
var corner_radius := float(UiStyle.RADIUS_CARD)
var diameter := 160.0:
	set(value):
		diameter = value
		if not fill:
			custom_minimum_size = Vector2(diameter, diameter)

func _init():
	diameter = 160.0
	custom_minimum_size = Vector2(diameter, diameter)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_diameter(d: float) -> void:
	diameter = d
	custom_minimum_size = Vector2(diameter, diameter)


## Porträt füllt die ganze Fläche des Controls (abgerundete Ecken statt Kreis).
func set_fill(on: bool) -> void:
	fill = on
	custom_minimum_size = Vector2.ZERO if on else Vector2(diameter, diameter)
	queue_redraw()


func set_profile(p: SparProfile) -> void:
	profile = p
	queue_redraw()


func shown_initials() -> String:
	if profile != null:
		return profile.initials()
	return "?"


func ring_color() -> Color:
	if profile != null:
		return profile.color.lightened(0.3)
	return UiStyle.MUTED


## Zahl 0..n-1, fest aus der Profil-ID abgeleitet (für Frisur und Farben).
func variant(salt: int, n: int) -> int:
	if profile == null:
		return 0
	return absi(hash(profile.id + str(salt))) % n


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var area := Rect2(Vector2.ZERO, size if fill else Vector2(diameter, diameter))
	if area.size.x < 2.0 or area.size.y < 2.0:
		return
	var clip := _rounded_rect(area, corner_radius) if fill else _ellipse(area.get_center(), area.size.x / 2.0, area.size.y / 2.0, 0.0, TAU, 64)
	var base := profile.color if profile != null else UiStyle.RAISED

	# Hintergrund: Verlauf von hell (oben) nach dunkel (unten)
	_gradient_polygon(clip, area, base.lightened(0.25), base.darkened(0.6))
	# weicher Lichtfleck hinter dem Kopf
	var unit := minf(area.size.x, area.size.y)
	var r := unit * (0.17 if fill else 0.2)
	var head := Vector2(area.get_center().x, area.position.y + (area.size.y * 0.3 if fill else area.size.y * 0.45))
	_clipped(_ellipse(head + Vector2(0, r * 0.4), r * 1.9, r * 1.9, 0.0, TAU, 48), clip, Color(1, 1, 1, 0.07))

	if profile == null:
		_draw_initials(area)
		_draw_ring(area)
		return

	var skin: Color = SKIN[variant(1, SKIN.size())]
	var hair: Color = HAIR[variant(2, HAIR.size())]
	var style := variant(3, STYLES)
	var shirt := base.darkened(0.35)

	# lange Haare liegen hinter Kopf und Schultern
	if style == 1:
		_clipped(_ellipse(head + Vector2(0, r * 0.55), r * 1.25, r * 1.65, 0.0, TAU, 40), clip, hair)
	# Schultern und Oberkörper
	_clipped(_ellipse(head + Vector2(0, r * 3.1), r * 2.3, r * 1.8, 0.0, TAU, 48), clip, shirt)
	_clipped(_ellipse(head + Vector2(0, r * 3.1), r * 2.3, r * 1.8, PI * 1.15, PI * 1.85, 24), clip, shirt.lightened(0.12))
	# Hals mit Ausschnitt
	_clipped(PackedVector2Array([head + Vector2(-r * 0.38, r * 0.5), head + Vector2(r * 0.38, r * 0.5), head + Vector2(r * 0.42, r * 1.55), head + Vector2(0, r * 1.95), head + Vector2(-r * 0.42, r * 1.55)]), clip, skin.darkened(0.12))
	# Ohren und Kopf
	for side in [-1.0, 1.0]:
		_clipped(_ellipse(head + Vector2(side * r * 0.95, r * 0.12), r * 0.18, r * 0.24, 0.0, TAU, 16), clip, skin.darkened(0.08))
	_clipped(_ellipse(head, r * 0.92, r, 0.0, TAU, 40), clip, skin)
	# Glanzlicht oben links
	_clipped(_ellipse(head + Vector2(-r * 0.35, -r * 0.4), r * 0.35, r * 0.25, 0.0, TAU, 20), clip, Color(1, 1, 1, 0.12))
	# Frisur
	match style:
		0:
			_clipped(_hair_cap(head, r, 1.0), clip, hair)
		1:
			_clipped(_hair_cap(head, r, 1.05), clip, hair)
		2:
			_clipped(_hair_cap(head, r, 0.95), clip, hair)
			_clipped(_ellipse(head + Vector2(0, -r * 1.12), r * 0.42, r * 0.36, 0.0, TAU, 24), clip, hair)
		_:
			_clipped(_hair_cap(head, r, 0.9), clip, Color(hair, 0.75))
	# Gesicht: Augen und Lächeln
	var eye := Color("#1B1B22")
	for side in [-1.0, 1.0]:
		_clipped(_ellipse(head + Vector2(side * r * 0.34, r * 0.08), r * 0.08, r * 0.1, 0.0, TAU, 12), clip, eye)
	draw_arc(head + Vector2(0, r * 0.3), r * 0.28, PI * 0.2, PI * 0.8, 12, skin.darkened(0.4), maxf(1.5, r * 0.06), true)
	if not fill:
		_draw_ring(area)


func _draw_ring(area: Rect2) -> void:
	draw_arc(area.get_center(), area.size.x / 2.0 - 2.0, 0.0, TAU, 64, ring_color(), 4.0, true)


func _draw_initials(area: Rect2) -> void:
	var font_size := int(minf(area.size.x, area.size.y) * 0.38)
	var font := ThemeDB.fallback_font
	var baseline := area.get_center().y + (font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5
	draw_string(font, Vector2(area.position.x, baseline), shown_initials(), HORIZONTAL_ALIGNMENT_CENTER, area.size.x, font_size, UiStyle.TEXT)


## Haaransatz: obere Kopfhälfte, etwas größer als der Kopf, mit leicht geschwungenem Pony.
func _hair_cap(head: Vector2, r: float, scale: float) -> PackedVector2Array:
	var pts := _ellipse(head + Vector2(0, -r * 0.08), r * 1.0 * scale, r * 1.0 * scale, PI, TAU, 24)
	pts.append(head + Vector2(r * 0.95 * scale, r * 0.05))
	pts.append(head + Vector2(r * 0.55, -r * 0.35))
	pts.append(head + Vector2(-r * 0.1, -r * 0.5))
	pts.append(head + Vector2(-r * 0.7, -r * 0.3))
	pts.append(head + Vector2(-r * 0.95 * scale, r * 0.05))
	return pts


func _clipped(poly: PackedVector2Array, clip: PackedVector2Array, color: Color) -> void:
	for part in Geometry2D.intersect_polygons(poly, clip):
		if part.size() >= 3:
			draw_colored_polygon(part, color)


func _gradient_polygon(poly: PackedVector2Array, area: Rect2, top: Color, bottom: Color) -> void:
	var colors := PackedColorArray()
	for p in poly:
		colors.append(top.lerp(bottom, clampf((p.y - area.position.y) / area.size.y, 0.0, 1.0)))
	draw_polygon(poly, colors)


static func _ellipse(c: Vector2, rx: float, ry: float, from: float, to: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var closed := is_equal_approx(to - from, TAU)
	var count := n if closed else n + 1
	for i in count:
		var a := from + (to - from) * i / n
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


static func _rounded_rect(rect: Rect2, radius: float) -> PackedVector2Array:
	var r := minf(radius, minf(rect.size.x, rect.size.y) / 2.0)
	var pts := PackedVector2Array()
	var corners := [
		[rect.position + Vector2(rect.size.x - r, r), -PI / 2.0],
		[rect.end - Vector2(r, r), 0.0],
		[rect.position + Vector2(r, rect.size.y - r), PI / 2.0],
		[rect.position + Vector2(r, r), PI],
	]
	for c in corners:
		for i in 7:
			var a: float = c[1] + PI / 2.0 * i / 6.0
			pts.append(c[0] + Vector2(cos(a), sin(a)) * r)
	return pts
