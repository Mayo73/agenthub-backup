extends Node2D
## Hauptszene der Zellenphase. Verdrahtet Spielerzelle, Nahrung, KI-Zellen, Kamera und HUD.
## Die Logik steckt in RefCounted-Klassen unter scripts/, hier nur Verdrahtung.

@onready var world: Node2D = $World
@onready var camera: Camera2D = $Camera

var player: PlayerCell


func _ready() -> void:
	Controls.setup()
	player = PlayerCell.new()
	player.name = "Player"
	world.add_child(player)
	camera.zoom = Vector2.ONE * CameraZoom.target_for_radius(player.radius)


func _process(delta: float) -> void:
	camera.position = player.position
	var zoom := CameraZoom.smooth(camera.zoom.x, CameraZoom.target_for_radius(player.radius), delta)
	camera.zoom = Vector2(zoom, zoom)
