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


func _process(_delta: float) -> void:
	camera.position = player.position
