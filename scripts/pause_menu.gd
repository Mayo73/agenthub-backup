extends CanvasLayer

signal restart_requested

const MENU_SCENE := "res://scenes/main_menu.tscn"

@onready var resume_button: Button = $Buttons/Resume
@onready var restart_button: Button = $Buttons/Restart
@onready var menu_button: Button = $Buttons/Menu


func _ready() -> void:
	visible = false
	resume_button.pressed.connect(_on_resume)
	restart_button.pressed.connect(_on_restart)
	menu_button.pressed.connect(_on_menu)


func open() -> void:
	visible = true
	get_tree().paused = true
	resume_button.grab_focus()


func close() -> void:
	visible = false
	get_tree().paused = false


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle()
		get_viewport().set_input_as_handled()


func _on_resume() -> void:
	close()


func _on_restart() -> void:
	close()
	restart_requested.emit()


func _on_menu() -> void:
	close()
	get_tree().change_scene_to_file(MENU_SCENE)
