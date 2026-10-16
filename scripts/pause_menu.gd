class_name PauseMenu
extends CanvasLayer
## Pausemenü. Nur Darstellung und Signale; main.gd hält das Spiel an.

signal resume
signal open_settings
signal to_main_menu
signal quit_game

var box: VBoxContainer
var resume_button: Button
var settings_button: Button
var main_menu_button: Button
var quit_button: Button


func _init() -> void:
	layer = 9
	process_mode = Node.PROCESS_MODE_ALWAYS
	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.color = Color(0, 0, 0, 0.6)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	box = VBoxContainer.new()
	box.name = "Box"
	box.position = Vector2(760, 320)
	box.add_theme_constant_override("separation", 16)
	add_child(box)
	var title := Label.new()
	title.name = "Title"
	title.text = "Pause"
	title.add_theme_font_size_override("font_size", 48)
	box.add_child(title)
	resume_button = _button("Weiter")
	settings_button = _button("Einstellungen")
	main_menu_button = _button("Hauptmenü")
	quit_button = _button("Beenden")
	resume_button.pressed.connect(func() -> void: resume.emit())
	settings_button.pressed.connect(func() -> void: open_settings.emit())
	main_menu_button.pressed.connect(func() -> void: to_main_menu.emit())
	quit_button.pressed.connect(func() -> void: quit_game.emit())
	visible = false


func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(400, 56)
	b.add_theme_font_size_override("font_size", 26)
	box.add_child(b)
	return b


func open() -> void:
	visible = true


func close() -> void:
	visible = false
