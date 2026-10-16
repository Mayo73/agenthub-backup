class_name EndScreen
extends CanvasLayer
## Abschlussbildschirm der Zellenphase mit Entwicklungsrückblick. Nur Darstellung und Signale.

signal to_main_menu
signal quit_game

var box: VBoxContainer
var title_label: Label
var lines_box: VBoxContainer
var menu_button: Button
var quit_button: Button


func _init() -> void:
	layer = 12
	process_mode = Node.PROCESS_MODE_ALWAYS
	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.04, 0.17, 0.24, 0.97)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	box = VBoxContainer.new()
	box.name = "Box"
	box.position = Vector2(660, 200)
	box.add_theme_constant_override("separation", 14)
	add_child(box)
	title_label = Label.new()
	title_label.name = "Title"
	title_label.text = "Die Zellenphase ist geschafft!"
	title_label.add_theme_font_size_override("font_size", 48)
	box.add_child(title_label)
	lines_box = VBoxContainer.new()
	lines_box.name = "Lines"
	box.add_child(lines_box)
	menu_button = Button.new()
	menu_button.text = "Hauptmenü"
	menu_button.custom_minimum_size = Vector2(400, 56)
	box.add_child(menu_button)
	quit_button = Button.new()
	quit_button.text = "Beenden"
	quit_button.custom_minimum_size = Vector2(400, 56)
	box.add_child(quit_button)
	menu_button.pressed.connect(func() -> void: to_main_menu.emit())
	quit_button.pressed.connect(func() -> void: quit_game.emit())
	visible = false


## Zeigt den Rückblick: die Zeilen von stats.summary_lines() und die Hauptnahrung.
func show_stats(stats: RunStats) -> void:
	for child in lines_box.get_children():
		lines_box.remove_child(child)
		child.free()
	var lines := stats.summary_lines()
	lines.append("Hauptnahrung: " + diet_name(stats.main_diet()))
	for line in lines:
		var l := Label.new()
		l.text = line
		l.add_theme_font_size_override("font_size", 28)
		lines_box.add_child(l)
	visible = true


## Deutscher Name einer Ernährungsart.
static func diet_name(diet: String) -> String:
	if diet == Diet.PFLANZENFRESSER:
		return "Pflanzenfresser"
	if diet == Diet.FLEISCHFRESSER:
		return "Fleischfresser"
	if diet == Diet.ALLESFRESSER:
		return "Allesfresser"
	return "unbekannt"
