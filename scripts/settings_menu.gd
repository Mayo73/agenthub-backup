class_name SettingsMenu
extends CanvasLayer
## Einstellungsmenü: Lautstärken, Vollbild, Auflösung. Änderungen gehen sofort in das UserSettings-Objekt.

signal closed

var settings: UserSettings
var box: VBoxContainer
var music_slider: HSlider
var sfx_slider: HSlider
var fullscreen_check: CheckBox
var resolution_option: OptionButton
var difficulty_option: OptionButton
var back_button: Button


func _init() -> void:
	layer = 11
	process_mode = Node.PROCESS_MODE_ALWAYS
	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.04, 0.17, 0.24, 0.95)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	box = VBoxContainer.new()
	box.name = "Box"
	box.position = Vector2(760, 260)
	box.add_theme_constant_override("separation", 12)
	add_child(box)
	_label("Musik")
	music_slider = _slider()
	_label("Effekte")
	sfx_slider = _slider()
	fullscreen_check = CheckBox.new()
	fullscreen_check.text = "Vollbild"
	box.add_child(fullscreen_check)
	_label("Auflösung")
	resolution_option = OptionButton.new()
	for r in UserSettings.RESOLUTIONS:
		resolution_option.add_item("%d × %d" % [r.x, r.y])
	box.add_child(resolution_option)
	_label("Schwierigkeit")
	difficulty_option = OptionButton.new()
	for n: String in Difficulty.NAMES:
		difficulty_option.add_item(n)
	box.add_child(difficulty_option)
	back_button = Button.new()
	back_button.text = "Zurück"
	back_button.custom_minimum_size = Vector2(400, 56)
	box.add_child(back_button)
	music_slider.value_changed.connect(_on_music)
	sfx_slider.value_changed.connect(_on_sfx)
	fullscreen_check.toggled.connect(_on_fullscreen)
	resolution_option.item_selected.connect(_on_resolution)
	difficulty_option.item_selected.connect(_on_difficulty)
	back_button.pressed.connect(close)
	visible = false


func _on_music(v: float) -> void:
	if settings != null:
		settings.set_music_volume(v)


func _on_sfx(v: float) -> void:
	if settings != null:
		settings.set_sfx_volume(v)


func _on_fullscreen(on: bool) -> void:
	if settings != null:
		settings.fullscreen = on


func _on_resolution(i: int) -> void:
	if settings != null:
		settings.set_resolution_index(i)


func _on_difficulty(i: int) -> void:
	if settings != null:
		settings.set_difficulty(i)


func _label(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 24)
	box.add_child(l)


func _slider() -> HSlider:
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.custom_minimum_size = Vector2(400, 32)
	box.add_child(s)
	return s


## Zeigt die Werte von s an und öffnet das Menü.
func show_settings(s: UserSettings) -> void:
	settings = s
	music_slider.value = s.music_volume
	sfx_slider.value = s.sfx_volume
	fullscreen_check.button_pressed = s.fullscreen
	resolution_option.select(s.resolution_index)
	difficulty_option.select(s.difficulty)
	visible = true


func close() -> void:
	visible = false
	closed.emit()
