extends Control

const MENU_SCENE := "res://scenes/main_menu.tscn"

var settings_path := UserSettings.DEFAULT_PATH
var settings: UserSettings

@onready var volume_slider: HSlider = $Items/VolumeRow/Volume
@onready var fullscreen_box: CheckBox = $Items/Fullscreen
@onready var back_button: Button = $Items/Back

func _ready() -> void:
	settings = UserSettings.load_from(settings_path)
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
