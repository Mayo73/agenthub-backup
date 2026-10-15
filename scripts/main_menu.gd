extends Control

const GAME_SCENE := "res://scenes/main.tscn"

@onready var start_button: Button = $Buttons/Start
@onready var settings_button: Button = $Buttons/Settings
@onready var quit_button: Button = $Buttons/Quit

func _ready() -> void:
	start_button.pressed.connect(start_game)
	quit_button.pressed.connect(quit_game)
	start_button.grab_focus()

func start_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)

func quit_game() -> void:
	get_tree().quit()
