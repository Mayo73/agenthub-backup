class_name AvatarView
extends Control

## Zeigt den Avatar eines SparProfile als selbst gezeichnetes, illustriertes Porträt:
## Hintergrund im Verlauf der Profilfarbe, Kopf mit Gesicht und Frisur, Hals und Schultern.
## Licht kommt von oben links (Schattenseite rechts). Rund (Listen, Kopfzeilen) oder als Fläche
## mit abgerundeten Ecken (Profilkarte, `set_fill`), dort mit dunklem Verlauf am unteren Rand (`shade`).
## Keine externen Bilddateien, alles wird per Code gezeichnet; Frisur, Haar-, Haut- und Augenfarbe
## folgen fest aus der Profil-ID, sehen also immer gleich aus.

const SKIN := [Color("#F1C7A5"), Color("#E0AC88"), Color("#C68A62"), Color("#8D5A3B"), Color("#5C3A24")]
const HAIR := [Color("#2B1D14"), Color("#121212"), Color("#C9A24A"), Color("#7A3B1E"), Color("#5A4632")]
const IRIS := [Color("#5B3A1E"), Color("#3E2A1A"), Color("#4A6B8A"), Color("#5E7A3A"), Color("#7A5A2A")]
## Frisuren: kurz, lang, Dutt, sehr kurz, Locken
const STYLES := 5

var profile: SparProfile = null
## Füllt die ganze Fläche statt eines Kreises (für die Profilkarte).
var fill := false
## Dunkler Verlauf in der unteren Hälfte, damit Text auf dem Porträt lesbar ist (nur mit fill).
var shade := false
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
	var unit := minf(area.size.x, area.size.y)
	var r := unit * (0.15 if fill else 0.19)
	var head := Vector2(area.get_center().x, area.position.y + (area.size.y * 0.3 if fill else area.size.y * 0.42))
	# weicher Lichtfleck hinter dem Kopf
	for i in 10:
		_clipped(_ellipse(head + Vector2(-r * 0.3, r * 0.2), r * (1.3 + i * 0.2), r * (1.3 + i * 0.2), 0.0, TAU, 48), clip, Color(1, 1, 1, 0.01))

	if profile == null:
		_draw_initials(area)
		_draw_ring(area)
		return

	var skin: Color = SKIN[variant(1, SKIN.size())]
	var hair: Color = HAIR[variant(2, HAIR.size())]
	var style := variant(3, STYLES)
	var iris: Color = IRIS[variant(4, IRIS.size())]
	var shirt := base.darkened(0.45)

	# lange Haare liegen hinter Kopf und Schultern
	if style == 1:
		_clipped(_long_hair_back(head, r), clip, hair.darkened(0.15))
	_draw_torso(head, r, clip, shirt, skin)
	_draw_head(head, r, clip, skin)
	_draw_face(head, r, clip, skin, hair, iris)
	_draw_hair(head, r, clip, hair, skin, style)

	if fill and shade:
		_draw_shade(area)
	if not fill:
		_draw_ring(area)


## Schultern im Shirt mit rundem Ausschnitt, Hals mit Schatten unter dem Kinn.
func _draw_torso(head: Vector2, r: float, clip: PackedVector2Array, shirt: Color, skin: Color) -> void:
	var torso := PackedVector2Array()
	var left := PackedVector2Array([
		head + Vector2(-r * 0.4, r * 1.45),
		head + Vector2(-r * 1.1, r * 1.75),
		head + Vector2(-r * 1.9, r * 1.95),
		head + Vector2(-r * 2.45, r * 2.3),
		head + Vector2(-r * 2.75, r * 2.9),
		head + Vector2(-r * 2.9, r * 3.8),
		head + Vector2(-r * 3.0, r * 7.0),
	])
	torso.append_array(left)
	for i in range(left.size() - 1, -1, -1):
		var p := left[i] - head
		torso.append(head + Vector2(-p.x, p.y))
	_clipped(torso, clip, shirt)
	# Schattenseite rechts, Licht auf der linken Schulter
	_clipped_both(torso, _ellipse(head + Vector2(r * 2.6, r * 3.6), r * 1.6, r * 2.6, 0.0, TAU, 32), clip, Color(0, 0, 0, 0.14))
	_clipped_both(torso, _ellipse(head + Vector2(-r * 2.0, r * 2.4), r * 0.8, r * 0.45, 0.0, TAU, 24), clip, Color(1, 1, 1, 0.07))
	# Hals mit rundem Ausschnitt
	var neck := PackedVector2Array([
		head + Vector2(-r * 0.32, r * 0.6),
		head + Vector2(r * 0.32, r * 0.6),
		head + Vector2(r * 0.38, r * 1.4),
	])
	neck.append_array(_ellipse(head + Vector2(0, r * 1.5), r * 0.62, r * 0.42, 0.0, PI, 16))
	neck.append(head + Vector2(-r * 0.38, r * 1.4))
	_clipped(neck, clip, skin.darkened(0.06))
	_clipped_both(neck, _ellipse(head + Vector2(0, r * 0.75), r * 0.7, r * 0.42, 0.0, TAU, 24), clip, Color(0, 0, 0, 0.18))
	_clipped_both(neck, _ellipse(head + Vector2(r * 0.55, r * 1.3), r * 0.35, r * 0.7, 0.0, TAU, 20), clip, Color(0, 0, 0, 0.1))
	# Saum des Ausschnitts
	draw_polyline(_ellipse(head + Vector2(0, r * 1.5), r * 0.62, r * 0.42, 0.05, PI - 0.05, 16), shirt.lightened(0.18), maxf(1.5, r * 0.07), true)


## Kopf mit Kinn und Kieferlinie, Ohren, Schattenseite rechts und Glanzlicht links.
func _draw_head(head: Vector2, r: float, clip: PackedVector2Array, skin: Color) -> void:
	for side: float in [-1.0, 1.0]:
		var ear := head + Vector2(side * r * 0.84, r * 0.12)
		_clipped(_ellipse(ear, r * 0.14, r * 0.22, 0.0, TAU, 16), clip, skin.darkened(0.08 if side < 0 else 0.16))
		_clipped(_ellipse(ear + Vector2(side * r * 0.02, 0), r * 0.06, r * 0.12, 0.0, TAU, 12), clip, skin.darkened(0.28))
	var face := _head_shape(head, r)
	_clipped(face, clip, skin)
	_clipped_both(face, _ellipse(head + Vector2(r * 1.12, r * 0.15), r * 0.5, r * 1.4, 0.0, TAU, 32), clip, Color(skin.darkened(0.35), 0.28))
	_clipped_both(face, _ellipse(head + Vector2(0, r * 1.35), r * 0.7, r * 0.32, 0.0, TAU, 24), clip, Color(skin.darkened(0.3), 0.15))
	_clipped_both(face, _ellipse(head + Vector2(-r * 0.38, -r * 0.42), r * 0.3, r * 0.2, 0.0, TAU, 20), clip, Color(1, 1, 1, 0.05))


## Augen mit Lid, Iris und Glanzpunkt, Brauen, Nase, Lippen, leichte Wangenröte.
func _draw_face(head: Vector2, r: float, clip: PackedVector2Array, skin: Color, hair: Color, iris: Color) -> void:
	var line := skin.darkened(0.55)
	var ey := head.y + r * 0.1
	for side: float in [-1.0, 1.0]:
		var ex := head.x + side * r * 0.33
		var w := r * 0.17
		var h := r * 0.085
		var upper := PackedVector2Array()
		var lower := PackedVector2Array()
		for i in 13:
			var t := -1.0 + 2.0 * i / 12.0
			var tilt := -side * t * r * 0.015
			upper.append(Vector2(ex + t * w, ey - h * (1.0 - t * t) + tilt))
			lower.append(Vector2(ex + t * w, ey + h * 0.6 * (1.0 - t * t) + tilt))
		var eye := upper.duplicate()
		for i in range(lower.size() - 2, 0, -1):
			eye.append(lower[i])
		_clipped(eye, clip, Color("#F2EDE8"))
		_clipped_both(_ellipse(Vector2(ex, ey), r * 0.075, r * 0.075, 0.0, TAU, 16), eye, clip, iris)
		_clipped_both(_ellipse(Vector2(ex, ey), r * 0.036, r * 0.036, 0.0, TAU, 12), eye, clip, Color("#141418"))
		draw_circle(Vector2(ex - r * 0.025, ey - r * 0.03), maxf(0.8, r * 0.016), Color(1, 1, 1, 0.9))
		draw_polyline(upper, line, maxf(1.2, r * 0.035), true)
		# Braue: innen kräftig, außen schmal, leicht gebogen
		var brow := PackedVector2Array()
		var brow_low := PackedVector2Array()
		for i in 9:
			var t := i / 8.0
			var x := head.x + side * lerpf(r * 0.12, r * 0.52, t)
			var y := ey - r * 0.2 - sin(t * PI * 0.85) * r * 0.05 + t * r * 0.02
			var thick := lerpf(r * 0.065, r * 0.025, t)
			brow.append(Vector2(x, y - thick * 0.5))
			brow_low.insert(0, Vector2(x, y + thick * 0.5))
		brow.append_array(brow_low)
		_clipped(brow, clip, hair.darkened(0.25).lerp(skin.darkened(0.5), 0.2))
	# Nase: Schattenkante auf der rechten Seite und Nasenflügel
	draw_polyline(PackedVector2Array([head + Vector2(r * 0.07, r * 0.2), head + Vector2(r * 0.1, r * 0.32), head + Vector2(r * 0.12, r * 0.42)]), Color(line, 0.45), maxf(1.0, r * 0.025), true)
	draw_arc(head + Vector2(0, r * 0.41), r * 0.1, PI * 0.15, PI * 0.85, 10, Color(line, 0.55), maxf(1.0, r * 0.028), true)
	_clipped(_ellipse(head + Vector2(r * 0.03, r * 0.5), r * 0.12, r * 0.04, 0.0, TAU, 12), clip, Color(skin.darkened(0.3), 0.35))
	# Lippen mit leichtem Lächeln
	var m := head.y + r * 0.66
	var lip := skin.darkened(0.2).lerp(Color("#B5545C"), 0.3)
	_clipped(PackedVector2Array([
		Vector2(head.x - r * 0.2, m - r * 0.02),
		Vector2(head.x - r * 0.08, m - r * 0.06),
		Vector2(head.x, m - r * 0.04),
		Vector2(head.x + r * 0.08, m - r * 0.06),
		Vector2(head.x + r * 0.2, m - r * 0.02),
		Vector2(head.x, m + r * 0.01),
	]), clip, lip.darkened(0.08))
	var lower_lip := _ellipse(Vector2(head.x, m), r * 0.16, r * 0.08, 0.0, PI, 12)
	lower_lip.append(Vector2(head.x - r * 0.16, m))
	_clipped(lower_lip, clip, lip)
	draw_polyline(PackedVector2Array([Vector2(head.x - r * 0.21, m - r * 0.03), Vector2(head.x - r * 0.1, m + r * 0.005), Vector2(head.x, m + r * 0.012), Vector2(head.x + r * 0.1, m + r * 0.005), Vector2(head.x + r * 0.21, m - r * 0.03)]), Color(line, 0.7), maxf(1.0, r * 0.022), true)
	for side: float in [-1.0, 1.0]:
		_clipped(_ellipse(head + Vector2(side * r * 0.5, r * 0.4), r * 0.16, r * 0.09, 0.0, TAU, 16), clip, Color(lip, 0.08))


func _draw_hair(head: Vector2, r: float, clip: PackedVector2Array, hair: Color, skin: Color, style: int) -> void:
	var sheen := Color(1, 1, 1, 0.1) if hair.get_luminance() < 0.4 else Color(1, 1, 1, 0.18)
	match style:
		0:
			_clipped(_hair_top(head, r, 1.07, -0.35), clip, hair)
		1:
			_clipped(_hair_top(head, r, 1.1, 0.0), clip, hair)
			for side: float in [-1.0, 1.0]:
				_clipped(PackedVector2Array([
					head + Vector2(side * r * 0.7, -r * 0.45),
					head + Vector2(side * r * 1.08, -r * 0.1),
					head + Vector2(side * r * 1.12, r * 1.0),
					head + Vector2(side * r * 1.0, r * 1.75),
					head + Vector2(side * r * 0.82, r * 1.2),
					head + Vector2(side * r * 0.8, r * 0.1),
				]), clip, hair)
		2:
			_clipped(_ellipse(head + Vector2(0, -r * 1.22), r * 0.42, r * 0.36, 0.0, TAU, 24), clip, hair)
			_clipped(_hair_top(head, r, 1.0, 0.0), clip, hair)
			draw_arc(head + Vector2(0, -r * 1.22), r * 0.3, PI * 0.15, PI * 0.85, 10, hair.lightened(0.25), maxf(1.0, r * 0.04), true)
		3:
			_clipped(_hair_top(head, r, 0.98, 0.0), clip, hair.lerp(skin, 0.3))
			sheen = Color(1, 1, 1, 0.0)
		_:
			for i in 11:
				var a := PI * (1.02 + 0.96 * i / 10.0)
				_clipped(_ellipse(head + Vector2(cos(a) * r * 0.92, -r * 0.1 + sin(a) * r * 1.02), r * 0.3, r * 0.3, 0.0, TAU, 16), clip, hair if i % 2 == 0 else hair.lightened(0.06))
			_clipped(_hair_top(head, r, 1.08, 0.2), clip, hair)
	if sheen.a > 0.0:
		draw_arc(head + Vector2(0, -r * 0.1), r * 0.88, PI * 1.18, PI * 1.42, 12, sheen, maxf(1.5, r * 0.09), true)


## Haar auf dem Kopf: Oberseite etwas größer als der Kopf, Haaransatz mit Scheitel bei `part` (−1 links … 1 rechts).
func _hair_top(head: Vector2, r: float, scale: float, part: float) -> PackedVector2Array:
	var pts := _ellipse(head + Vector2(0, -r * 0.12), r * 0.93 * scale, r * 1.08 * scale, PI * 0.97, PI * 2.03, 28)
	pts.append(head + Vector2(r * 0.86, r * 0.02))
	pts.append(head + Vector2(r * 0.74, -r * 0.3))
	pts.append(head + Vector2(r * (0.4 + part * 0.2), -r * 0.5))
	pts.append(head + Vector2(r * part * 0.5, -r * 0.62))
	pts.append(head + Vector2(-r * (0.4 - part * 0.2), -r * 0.48))
	pts.append(head + Vector2(-r * 0.74, -r * 0.28))
	pts.append(head + Vector2(-r * 0.86, r * 0.02))
	return pts


## Lange Haare hinter Kopf und Schultern, unten abgerundet.
func _long_hair_back(head: Vector2, r: float) -> PackedVector2Array:
	var pts := _ellipse(head + Vector2(0, -r * 0.05), r * 1.18, r * 1.2, PI, TAU, 24)
	pts.append(head + Vector2(r * 1.25, r * 1.6))
	pts.append_array(_ellipse(head + Vector2(0, r * 1.6), r * 1.25, r * 0.7, 0.0, PI, 16))
	pts.append(head + Vector2(-r * 1.25, r * 1.6))
	return pts


## Ei-förmiger Kopf: oben rund, zum Kinn hin schmaler (Kieferlinie).
func _head_shape(head: Vector2, r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 48:
		var a := TAU * i / 48.0
		var x := cos(a) * r * 0.86
		var y := sin(a) * r * 1.1
		if y > 0.0:
			var t := y / (r * 1.1)
			x *= lerpf(1.0, 0.55, pow(t, 1.8))
		pts.append(head + Vector2(x, y))
	return pts


## Dunkler Verlauf in der unteren Hälfte der Fläche, innerhalb der abgerundeten Ecken.
## In schmalen Streifen mit exakt berechneten Rändern, damit keine Nähte entstehen.
func _draw_shade(area: Rect2) -> void:
	const STEPS := 32
	var top := area.position.y + area.size.y * 0.42
	var r := minf(corner_radius, minf(area.size.x, area.size.y) / 2.0)
	for i in STEPS:
		var ya := lerpf(top, area.end.y, float(i) / STEPS)
		var yb := lerpf(top, area.end.y, float(i + 1) / STEPS)
		var ia := _inset(area, r, ya)
		var ib := _inset(area, r, yb)
		var ca := Color(0, 0, 0, _shade_alpha(float(i) / STEPS))
		var cb := Color(0, 0, 0, _shade_alpha(float(i + 1) / STEPS))
		draw_polygon(PackedVector2Array([Vector2(area.position.x + ia, ya), Vector2(area.end.x - ia, ya), Vector2(area.end.x - ib, yb), Vector2(area.position.x + ib, yb)]), PackedColorArray([ca, ca, cb, cb]))


## Deckkraft des Verlaufs: oben 0, schnell dunkler, unten 0.94.
static func _shade_alpha(t: float) -> float:
	return 0.94 * (1.0 - pow(1.0 - t, 1.8))


## Abstand vom Rand in Höhe y, den die abgerundeten unteren Ecken einnehmen.
static func _inset(area: Rect2, r: float, y: float) -> float:
	var dy := y - (area.end.y - r)
	if dy <= 0.0:
		return 0.0
	return r - sqrt(maxf(0.0, r * r - dy * dy))


func _draw_ring(area: Rect2) -> void:
	draw_arc(area.get_center(), area.size.x / 2.0 - 2.0, 0.0, TAU, 64, ring_color(), 4.0, true)


func _draw_initials(area: Rect2) -> void:
	var font_size := int(minf(area.size.x, area.size.y) * 0.38)
	var font := ThemeDB.fallback_font
	var baseline := area.get_center().y + (font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5
	draw_string(font, Vector2(area.position.x, baseline), shown_initials(), HORIZONTAL_ALIGNMENT_CENTER, area.size.x, font_size, UiStyle.TEXT)


func _clipped(poly: PackedVector2Array, clip: PackedVector2Array, color: Color) -> void:
	for part in Geometry2D.intersect_polygons(poly, clip):
		if part.size() >= 3:
			draw_colored_polygon(part, color)


## Zeichnet die Schnittfläche von `poly` und `inside`, beschnitten auf `clip` (für Schatten und Lichter).
func _clipped_both(poly: PackedVector2Array, inside: PackedVector2Array, clip: PackedVector2Array, color: Color) -> void:
	for part in Geometry2D.intersect_polygons(poly, inside):
		if part.size() >= 3:
			_clipped(part, clip, color)


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
