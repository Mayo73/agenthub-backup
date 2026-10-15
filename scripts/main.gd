extends Node2D
## Hauptszene: Steuerung anlegen, isometrische Ansicht einrichten, Auto an den Start setzen,
## Kamera, HUD, Drift-Wertung und Rundenzeit nachführen.

const MENU_SCENE := "res://scenes/main_menu.tscn"

## Die Kamera schaut in Fahrtrichtung voraus (Sekunden).
const LOOK_AHEAD := 0.35

@onready var world: Node2D = $World
@onready var track: Node2D = $World/Track
@onready var car: Node2D = $World/Car
@onready var camera: Camera2D = $Camera2D
@onready var hud: CanvasLayer = $HUD

var scorer := DriftScorer.new()
var lap_timer: LapTimer
var skid_marks: Node2D
var race := RaceState.new()
var pause_menu: CanvasLayer
var ghost: Node2D
var ghost_best: GhostLap = null
var ghost_recording := GhostLap.new()

var highscore_path := HighscoreTable.DEFAULT_PATH
var last_record := {}


func _ready() -> void:
	Controls.setup()
	track.load_track(GameSettings.track_id)
	world.transform = Iso.TRANSFORM
	car.track = track.path
	car.place_at_start()
	camera.position = Iso.to_screen(car.physics.position)
	camera.reset_smoothing()
	lap_timer = LapTimer.new(track.path.length)
	lap_timer.lap_completed.connect(_on_lap_completed)
	car.input_enabled = race.can_drive()

	skid_marks = preload("res://scripts/skid_marks.gd").new()
	skid_marks.name = "SkidMarks"
	world.add_child(skid_marks)
	world.move_child(skid_marks, car.get_index())

	ghost = preload("res://scripts/ghost_car.gd").new()
	ghost.name = "Ghost"
	world.add_child(ghost)
	world.move_child(ghost, car.get_index())

	pause_menu = preload("res://scenes/pause_menu.tscn").instantiate()
	add_child(pause_menu)
	pause_menu.restart_requested.connect(restart)
	hud.again_pressed.connect(restart)
	hud.menu_pressed.connect(go_to_menu)


func _physics_process(delta: float) -> void:
	race.update(delta)
	car.input_enabled = race.can_drive()
	camera.position = Iso.to_screen(car.physics.position + car.physics.velocity * LOOK_AHEAD)
	hud.show_car(car.physics)

	var pos: Vector2 = car.physics.position
	if race.phase == RaceState.Phase.RACING:
		scorer.update(delta, car.physics.slip_angle_deg(), car.physics.speed(), track.path.is_on_track(pos))
		lap_timer.update(delta, track.path.progress_at(pos))
		ghost_recording.record(lap_timer.current_time, car.physics.position, car.physics.heading)
	ghost.show_at(ghost_best, lap_timer.current_time)
	hud.show_score(scorer)
	hud.show_laps(lap_timer)
	hud.show_race(race, scorer.total)

	skid_marks.track_car(car.physics)

	if race.phase == RaceState.Phase.FINISHED and Input.is_action_just_pressed("neustart"):
		restart()


func _on_lap_completed(_lap_number: int, time: float, _is_best: bool) -> void:
	if ghost_best == null or time < ghost_best.duration():
		ghost_best = ghost_recording
	ghost_recording = GhostLap.new()
	race.on_lap(time)
	if race.phase == RaceState.Phase.FINISHED:
		record_result()


## Trägt das fertige Rennen in die Bestenliste ein und merkt sich, was neu ist.
func record_result() -> void:
	var table := HighscoreTable.load_from(highscore_path)
	last_record = table.submit(track.track_id, race.race_time, scorer.total)
	table.save(highscore_path)


func restart() -> void:
	race.reset()
	scorer.reset()
	lap_timer.reset()
	car.place_at_start()
	skid_marks.clear()
	car.input_enabled = race.can_drive()
	ghost_recording = GhostLap.new()
	last_record = {}


func go_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
