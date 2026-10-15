extends Node2D
## Hauptszene: Steuerung anlegen, isometrische Ansicht einrichten, Auto an den Start setzen,
## Kamera und HUD nachführen.
## Die Kamera schaut in Fahrtrichtung voraus (Sekunden).

## Rundenzeit-Messung für Drift-Spiel
const LOOK_AHEAD := 0.35

@onready var world: Node2D = $World
@onready var track: Node2D = $World/Track
@onready var car: Node2D = $World/Car
@onready var camera: Camera2D = $Camera2D
@onready var hud: CanvasLayer = $HUD

var scorer := DriftScorer.new()
var lap_timer: LapTimer


func _ready() -> void:
	Controls.setup()
	world.transform = Iso.TRANSFORM
	car.track = track.path
	car.place_at_start()
	camera.position = Iso.to_screen(car.physics.position)
	camera.reset_smoothing()
	lap_timer = LapTimer.new(track.path.length)


func _physics_process(delta: float) -> void:
	camera.position = Iso.to_screen(car.physics.position + car.physics.velocity * LOOK_AHEAD)
	hud.show_car(car.physics)

	var pos: Vector2 = car.physics.position
	scorer.update(delta, car.physics.slip_angle_deg(), car.physics.speed(), track.path.is_on_track(pos))
	lap_timer.update(delta, track.path.progress_at(pos))
	hud.show_score(scorer)
	hud.show_laps(lap_timer)
