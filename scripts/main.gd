extends Node2D
## Hauptszene: Steuerung anlegen, isometrische Ansicht einrichten, Auto an den Start setzen,
## Kamera und HUD nachführen.

## Die Kamera schaut in Fahrtrichtung voraus (Sekunden).
const LOOK_AHEAD := 0.35

@onready var world: Node2D = $World
@onready var track: Node2D = $World/Track
@onready var car: Node2D = $World/Car
@onready var camera: Camera2D = $Camera2D
@onready var hud: CanvasLayer = $HUD


func _ready() -> void:
	Controls.setup()
	world.transform = Iso.TRANSFORM
	car.track = track.path
	car.place_at_start()
	camera.position = Iso.to_screen(car.physics.position)
	camera.reset_smoothing()


func _physics_process(_delta: float) -> void:
	camera.position = Iso.to_screen(car.physics.position + car.physics.velocity * LOOK_AHEAD)
	hud.show_car(car.physics)
