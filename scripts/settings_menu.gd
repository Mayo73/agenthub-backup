extends Control

const MENU_SCENE := "res://scenes/main_menu.tscn"

var settings_path := UserSettings.DEFAULT_PATH
var settings: UserSettings
var key_buttons := {}
var waiting_action := ""
var click_player: AudioStreamPlayer

@onready var volume_slider: HSlider = $Items/VolumeRow/Volume
@onready var fullscreen_box: CheckBox = $Items/Fullscreen
@onready var back_button: Button = $Items/Back

func _ready() -> void:
	click_player = AudioStreamPlayer.new()
	click_player.name = "Click"
	click_player.stream = SoundBank.click()
	add_child(click_player)
	settings = UserSettings.load_from(settings_path)
	Controls.setup()
	Controls.apply_bindings(settings.keys)
	_build_key_rows()

	volume_slider.value = settings.volume
	fullscreen_box.button_pressed = settings.fullscreen

	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_box.toggled.connect(_on_fullscreen_toggled)
	back_button.pressed.connect(go_back)

	back_button.grab_focus()


func _on_volume_changed(value: float) -> void:
	settings.volume = value
	settings.apply()


func _on_fullscreen_toggled(on: bool) -> void:
	settings.fullscreen = on
	settings.apply()


func save_settings() -> void:
	settings.save(settings_path)


func go_back() -> void:
	save_settings()
	get_tree().change_scene_to_file(MENU_SCENE)


# Eine Zeile je Aktion: Name und Knopf mit der aktuellen Taste, vor „Zurück".
func _build_key_rows() -> void:
	var grid := GridContainer.new()
	grid.name = "Keys"
	grid.columns = 2
	$Items.add_child(grid)
	$Items.move_child(grid, back_button.get_index())
	for action in Controls.ACTIONS:
		var label := Label.new()
		label.text = Controls.LABELS[action]
		label.custom_minimum_size = Vector2(200, 0)
		grid.add_child(label)
		var button := Button.new()
		button.name = action
		button.custom_minimum_size = Vector2(180, 0)
		button.text = Controls.key_name(Controls.key_for(action))
		button.pressed.connect(start_rebind.bind(action))
		button.pressed.connect(play_click)
		grid.add_child(button)
		key_buttons[action] = button


# Wartet auf die nächste Taste für `action`.
func start_rebind(action: String) -> void:
	waiting_action = action
	key_buttons[action].text = "Taste drücken …"


# Übernimmt die gedrückte Taste; Esc bricht ab.
func handle_key(keycode: int) -> void:
	if waiting_action == "":
		return
	var action := waiting_action
	waiting_action = ""
	if keycode != KEY_ESCAPE:
		Controls.rebind_key(action, keycode)
		settings.keys[action] = keycode
	key_buttons[action].text = Controls.key_name(Controls.key_for(action))


func _input(event: InputEvent) -> void:
	if waiting_action != "" and event is InputEventKey and event.pressed and not event.echo:
		handle_key(event.physical_keycode)
		get_viewport().set_input_as_handled()


func play_click() -> void:
	if click_player and click_player.is_inside_tree():
		click_player.play()
