class_name UiStyle
extends RefCounted
## Farben, Schriftgrößen und Bausteine für die Oberfläche. Alle Bildschirme nutzen diese
## Funktionen, damit die App einheitlich aussieht.
##
## Stil (seit 20.10.2026, Vorbild moderne Dating-Apps, aber eigene Farben): fast schwarzer
## Hintergrund, dunkle Flächen mit weichen Schatten, große runde Ecken, eine violette
## Akzentfarbe mit türkisem Verlauf, runde Aktionsknöpfe, Chips für Merkmale.

const BG := Color("#0E0F14")
## Fläche für Karten, Listenzeilen und Knöpfe.
const CARD := Color("#1A1C24")
## Leicht hervorgehobene Fläche (Eingabefelder, gedrückte Zustände, Chips auf dunklem Grund).
const RAISED := Color("#262936")
const ACCENT := Color("#8B5CF6")
## Zweite Farbe des Akzentverlaufs (ACCENT → ACCENT_2).
const ACCENT_2 := Color("#22D3EE")
const TEXT := Color("#F5F5F7")
const MUTED := Color("#9CA3AF")
## Farbe der Demo-Kennzeichnung (Prototyp-Hinweis, Perspektivwechsel).
const DEMO := Color(0.98, 0.80, 0.25)
const LIKE := Color("#34D399")
const PASS := Color("#F87171")
const SHADOW := Color(0, 0, 0, 0.5)

const SIZE_SMALL := 22
const SIZE_NORMAL := 28
const SIZE_TITLE := 40
## Name auf der Profilkarte.
const SIZE_HERO := 56
## Mindesthöhe von Knöpfen, damit sie sich mit dem Finger gut treffen lassen.
const BUTTON_HEIGHT := 88
const RADIUS := 16
const RADIUS_CARD := 28
## Durchmesser der runden Aktionsknöpfe (Nein, Ja).
const ROUND_BUTTON := 112
## Abstand zwischen Elementen und zum Bildschirmrand.
const GAP := 16


static func label(text: String, size: int = SIZE_NORMAL, color: Color = TEXT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


## Beschriftung mit Schatten, gut lesbar auf Bildern.
static func overlay_label(text: String, size: int = SIZE_NORMAL) -> Label:
	var l := label(text, size, TEXT)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	l.add_theme_constant_override("shadow_offset_x", 0)
	l.add_theme_constant_override("shadow_offset_y", 2)
	l.add_theme_constant_override("shadow_outline_size", 6)
	return l


static func button(text: String, color: Color = CARD) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, BUTTON_HEIGHT)
	b.add_theme_font_size_override("font_size", SIZE_NORMAL)
	b.add_theme_color_override("font_color", TEXT)
	b.add_theme_color_override("font_hover_color", TEXT)
	b.add_theme_color_override("font_pressed_color", TEXT)
	b.add_theme_color_override("font_disabled_color", MUTED)
	_states(b, color, BUTTON_HEIGHT / 2)
	return b


## Runder Aktionsknopf mit Symbol (z. B. „✕“ für Nein, „♥“ für Ja): dunkle Fläche,
## farbiger Ring und Symbol in der Farbe der Aktion.
static func round_button(symbol: String, color: Color, diameter: int = ROUND_BUTTON) -> Button:
	var b := Button.new()
	b.text = symbol
	b.custom_minimum_size = Vector2(diameter, diameter)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.add_theme_font_size_override("font_size", int(diameter * 0.42))
	b.add_theme_color_override("font_color", color)
	b.add_theme_color_override("font_hover_color", color.lightened(0.2))
	b.add_theme_color_override("font_pressed_color", TEXT)
	b.add_theme_color_override("font_disabled_color", MUTED.darkened(0.3))
	var normal := circle(CARD, diameter, color)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", circle(RAISED, diameter, color))
	b.add_theme_stylebox_override("pressed", circle(color, diameter, color))
	b.add_theme_stylebox_override("disabled", circle(CARD.darkened(0.3), diameter, MUTED.darkened(0.4)))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return b


static func panel(color: Color, radius: int = RADIUS) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s


## Fläche mit weichem Schatten, z. B. für Karten und Dialoge.
static func card_panel(color: Color = CARD, radius: int = RADIUS_CARD) -> StyleBoxFlat:
	var s := panel(color, radius)
	s.shadow_color = SHADOW
	s.shadow_size = 18
	s.shadow_offset = Vector2(0, 6)
	s.anti_aliasing = true
	return s


## Kreisförmige Fläche mit Ring (für runde Knöpfe).
static func circle(color: Color, diameter: int, ring: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var s := panel(color, diameter / 2)
	s.set_content_margin_all(0)
	if ring.a > 0.0:
		s.set_border_width_all(3)
		s.border_color = ring
	s.shadow_color = SHADOW
	s.shadow_size = 12
	s.shadow_offset = Vector2(0, 4)
	return s


## Kleines abgerundetes Etikett, z. B. für Kampfsportart und Niveau. Die Beschriftung ist
## das einzige Kind des Etiketts und als `chip.get_child(0)` erreichbar.
static func chip(text: String, color: Color = ACCENT) -> PanelContainer:
	var c := PanelContainer.new()
	var s := panel(Color(color, 0.28), 999)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	s.set_border_width_all(2)
	s.border_color = Color(color, 0.7)
	c.add_theme_stylebox_override("panel", s)
	var l := label(text, SIZE_SMALL, TEXT)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	c.add_child(l)
	return c


## Senkrechter Verlauf als Textur, von `top` nach `bottom`.
static func vertical_gradient(top: Color, bottom: Color) -> GradientTexture2D:
	var g := Gradient.new()
	g.set_color(0, top)
	g.set_color(1, bottom)
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill_from = Vector2(0, 0)
	t.fill_to = Vector2(0, 1)
	t.width = 8
	t.height = 256
	return t


## Auswahlfeld (OptionButton) im Stil der App.
static func style_option(o: OptionButton) -> void:
	o.custom_minimum_size = Vector2(0, 64)
	o.add_theme_font_size_override("font_size", SIZE_SMALL)
	o.add_theme_color_override("font_color", TEXT)
	o.add_theme_stylebox_override("normal", panel(CARD, 999))
	o.add_theme_stylebox_override("hover", panel(RAISED, 999))
	o.add_theme_stylebox_override("pressed", panel(RAISED, 999))
	o.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


static func _states(b: Button, color: Color, radius: int) -> void:
	b.add_theme_stylebox_override("normal", panel(color, radius))
	b.add_theme_stylebox_override("hover", panel(color.lightened(0.1), radius))
	b.add_theme_stylebox_override("pressed", panel(color.darkened(0.15), radius))
	b.add_theme_stylebox_override("disabled", panel(color.darkened(0.35), radius))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
