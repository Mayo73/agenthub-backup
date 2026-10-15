extends Node2D
## Hauptszene: Steuerung anlegen, isometrische Ansicht einrichten, Auto an den Start setzen,
## Kamera, HUD, Drift-Wertung und Rundenzeit nachführen.

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


func _ready() -> void:
	Controls.setup()
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


func _physics_process(delta: float) -> void:
	race.update(delta)
	car.input_enabled = race.can_drive()
	camera.position = Iso.to_screen(car.physics.position + car.physics.velocity * LOOK_AHEAD)
	hud.show_car(car.physics)

	var pos: Vector2 = car.physics.position
	if race.phase == RaceState.Phase.RACING:
		scorer.update(delta, car.physics.slip_angle_deg(), car.physics.speed(), track.path.is_on_track(pos))
		lap_timer.update(delta, track.path.progress_at(pos))
	hud.show_score(scorer)
	hud.show_laps(lap_timer)
	hud.show_race(race, scorer.total)

	skid_marks.track_car(car.physics)

	if race.phase == RaceState.Phase.FINISHED and Input.is_action_just_pressed("neustart"):
		restart()


func _on_lap_completed(_lap_number: int, time: float, _is_best: bool) -> void:
	race.on_lap(time)


func restart() -> void:
	race.reset()
	scorer.reset()
	lap_timer.reset()
	car.place_at_start()
	car.input_enabled = race.can_drive()
