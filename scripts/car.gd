extends Node2D
## Das Auto in der Spielwelt: liest die Eingaben, rechnet die Fahrphysik und zeigt das Ergebnis.
## Liegt unter "World" (isometrisch projiziert) und arbeitet deshalb in Weltkoordinaten.

signal respawned

## Liegt das Auto weiter als so viel neben der Strecke, wird es automatisch zurückgesetzt.
const MAX_OFFTRACK := 500.0

var physics := CarPhysics.new()
var track: TrackPath


func _ready() -> void:
	Controls.setup()


func _physics_process(delta: float) -> void:
	physics.throttle = Input.get_action_strength("gas")
	physics.brake = Input.get_action_strength("bremse")
	physics.steer = Input.get_axis("links", "rechts")
	physics.handbrake = Input.is_action_pressed("handbremse")
	if track:
		var on_track := track.is_on_track(physics.position)
		physics.surface = CarPhysics.Surface.ROAD if on_track else CarPhysics.Surface.GRASS
	physics.step(delta)
	if track and (Input.is_action_just_pressed("zuruecksetzen")
			or track.distance_from_center(physics.position) > track.width * 0.5 + MAX_OFFTRACK):
		respawn()
	position = physics.position
	rotation = physics.heading


## Setzt das Auto an die Startlinie.
func place_at_start() -> void:
	_place(track.start_position(), track.start_heading())


## Setzt das Auto mit Blick in Fahrtrichtung auf die nächste Stelle der Mittellinie.
func respawn() -> void:
	var nearest: Vector2 = track.closest(physics.position)["position"]
	_place(nearest, track.direction_at(nearest).angle())
	respawned.emit()


func _place(world_position: Vector2, heading: float) -> void:
	physics.position = world_position
	physics.heading = heading
	physics.velocity = Vector2.ZERO
	physics.sliding = false
	position = world_position
	rotation = heading
	reset_physics_interpolation()
