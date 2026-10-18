class_name Main
extends Control
## Wurzel der App: Kopfzeile mit Prototyp-Hinweis, Inhaltsbereich für den aktuellen Bildschirm
## und Reiterleiste. Alle Bedienelemente entstehen im Code.

const SCREENS: Array[String] = ["entdecken", "matches", "profil"]
const TAB_TITLES := {"entdecken": "Entdecken", "matches": "Matches", "profil": "Profil"}

var banner: Label
## Hier hängt der aktuelle Bildschirm (genau ein Kind).
var content: Control
var tab_bar: HBoxContainer
## Bildschirmname -> Button der Reiterleiste
var tab_buttons: Dictionary = {}
var current_screen := ""
## Der aktuell angezeigte Bildschirm (Kind von content).
var screen: Control = null


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = UiStyle.BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var layout := VBoxContainer.new()
	layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(layout)

	var banner_box := PanelContainer.new()
	banner_box.add_theme_stylebox_override("panel", UiStyle.panel(UiStyle.DEMO, 0))
	banner = UiStyle.label("PROTOTYP · nur fiktive Testprofile", UiStyle.SIZE_SMALL, UiStyle.BG)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_box.add_child(banner)
	layout.add_child(banner_box)

	content = Control.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.clip_contents = true
	layout.add_child(content)

	tab_bar = HBoxContainer.new()
	for screen_name in SCREENS:
		var b := UiStyle.button(TAB_TITLES[screen_name])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(show_screen.bind(screen_name))
		tab_bar.add_child(b)
		tab_buttons[screen_name] = b
	layout.add_child(tab_bar)

	show_screen("entdecken")


## Zeigt einen Bildschirm im Inhaltsbereich; der vorherige wird entfernt.
func show_screen(screen_name: String) -> void:
	if screen != null:
		content.remove_child(screen)
		screen.queue_free()
	screen = _make_screen(screen_name)
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.add_child(screen)
	current_screen = screen_name
	for n in tab_buttons:
		(tab_buttons[n] as Button).disabled = n == screen_name


## Baut den Bildschirm zu einem Namen. Bis die echten Bildschirme per Ticket entstehen,
## zeigt er nur den Titel.
func _make_screen(screen_name: String) -> Control:
	var l := UiStyle.label(TAB_TITLES.get(screen_name, screen_name), UiStyle.SIZE_TITLE)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return l
