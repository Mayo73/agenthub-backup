extends Node2D
## Hauptszene der Zellenphase. Verdrahtet Spielerzelle, Nahrung, KI-Zellen, Kamera und HUD.
## Die Logik steckt in RefCounted-Klassen unter scripts/, hier nur Verdrahtung.

@onready var world: Node2D = $World
@onready var camera: Camera2D = $Camera


func _ready() -> void:
	Controls.setup()
