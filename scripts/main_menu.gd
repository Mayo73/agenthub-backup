class_name MainMenu
extends CanvasLayer
## Hauptmenü der Zellenphase. Nur Darstellung und Signale; main.gd entscheidet, was passiert.

signal new_game(diet: String)
signal continue_game
signal open_settings
signal quit_game

const TITLE_TEXTURE: Texture2D = preload("res://assets/ui/titelbild.png")

var box: VBoxContainer
var title_image: TextureRect
var title_label: Label
var herbivore_button: Button
var carnivore_button: Button
var continue_button: Button
var settings_button: Button
var quit_button: Button


func _init() -> void:
	layer = 10
	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color("#0B2B3D")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	title_image = TextureRect.new()
	title_image.name = "TitleImage"
	title_image.texture = TITLE_TEXTURE
	title_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	title_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title_image)
	box = VBoxContainer.new()
	box.name = "Box"
	box.position = Vector2(760, 280)
	box.add_theme_constant_override("separation", 16)
	add_child(box)
	title_label = Label.new()
	title_label.name = "Title"
	title_label.text = "Zellenphase"
	title_label.add_theme_font_size_override("font_size", 56)
	box.add_child(title_label)
	herbivore_button = _button("Neue Partie: Pflanzenfresser")
	carnivore_button = _button("Neue Partie: Fleischfresser")
	continue_button = _button("Fortsetzen")
	settings_button = _button("Einstellungen")
	quit_button = _button("Beenden")
	herbivore_button.pressed.connect(func() -> void: new_game.emit(Diet.PFLANZENFRESSER))
	carnivore_button.pressed.connect(func() -> void: new_game.emit(Diet.FLEISCHFRESSER))
	continue_button.pressed.connect(func() -> void: continue_game.emit())
	settings_button.pressed.connect(func() -> void: open_settings.emit())
	quit_button.pressed.connect(func() -> void: quit_game.emit())
	continue_button.disabled = true


func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(400, 56)
	b.add_theme_font_size_override("font_size", 26)
	box.add_child(b)
	return b


## Fortsetzen geht nur mit vorhandenem Spielstand.
func set_can_continue(value: bool) -> void:
	continue_button.disabled = not value
