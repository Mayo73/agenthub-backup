class_name UiStyle
extends RefCounted
## Farben, Schriftgrößen und Bausteine für die Oberfläche. Alle Bildschirme nutzen diese
## Funktionen, damit die App einheitlich aussieht.

const BG := Color(0.09, 0.10, 0.13)
const CARD := Color(0.16, 0.18, 0.23)
const ACCENT := Color(0.95, 0.45, 0.20)
const TEXT := Color(0.95, 0.95, 0.97)
const MUTED := Color(0.65, 0.68, 0.75)
## Farbe der Demo-Kennzeichnung (Prototyp-Hinweis, Perspektivwechsel).
const DEMO := Color(0.98, 0.80, 0.25)
const LIKE := Color(0.30, 0.78, 0.45)
const PASS := Color(0.85, 0.30, 0.30)

const SIZE_SMALL := 22
const SIZE_NORMAL := 28
const SIZE_TITLE := 40
## Mindesthöhe von Knöpfen, damit sie sich mit dem Finger gut treffen lassen.
const BUTTON_HEIGHT := 88


static func label(text: String, size: int = SIZE_NORMAL, color: Color = TEXT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


static func button(text: String, color: Color = CARD) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, BUTTON_HEIGHT)
	b.add_theme_font_size_override("font_size", SIZE_NORMAL)
	b.add_theme_color_override("font_color", TEXT)
	b.add_theme_stylebox_override("normal", panel(color))
	b.add_theme_stylebox_override("hover", panel(color.lightened(0.1)))
	b.add_theme_stylebox_override("pressed", panel(color.darkened(0.15)))
	b.add_theme_stylebox_override("disabled", panel(color.darkened(0.35)))
	return b


static func panel(color: Color, radius: int = 16) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s
