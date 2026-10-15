extends Control

const GAME_SCENE := "res://scenes/main.tscn"

@onready var start_button: Button = $Buttons/Start
@onready var settings_button: Button = $Buttons/Settings
@onready var quit_button: Button = $Buttons/Quit
@onready var track_prev: Button = $Buttons/TrackRow/TrackPrev
@onready var track_name: Label = $Buttons/TrackRow/TrackName
@onready var track_next: Button = $Buttons/TrackRow/TrackNext

func _ready() -> void:
	start_button.pressed.connect(start_game)
	quit_button.pressed.connect(quit_game)
	track_prev.pressed.connect(_on_track_prev)
	track_next.pressed.connect(_on_track_next)
	update_track_label()
	start_button.grab_focus()

func start_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)

func quit_game() -> void:
	get_tree().quit()

func update_track_label() -> void:
	track_name.text = TrackCatalog.name_of(GameSettings.track_id)

func _on_track_prev() -> void:
	GameSettings.previous_track()
	update_track_label()

func _on_track_next() -> void:
	GameSettings.next_track()
	update_track_label()
