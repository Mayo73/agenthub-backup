extends Node2D
## KI-Gegner: fährt mit AiDriver und CarPhysics, zeichnet sich als einfaches Auto.
## Liegt unter "World" und arbeitet in Weltkoordinaten.

const BODY := [Vector2(-25, -12), Vector2(21, -12), Vector2(26, -7), Vector2(26, 7), Vector2(21, 12), Vector2(-25, 12)]

var physics := CarPhysics.new()
var driver := AiDriver.new()
var track: TrackPath
var color := Color(0.55, 0.3, 0.8)
var driving_enabled := false


func _init() -> void:
	scale = Vector2(1.3, 1.3)


## Setzt das Auto still an eine Stelle.
func place_at(world_position: Vector2, heading: float) -> void:
	physics.position = world_position
	physics.heading = heading
	physics.velocity = Vector2.ZERO
	physics.sliding = false
	position = world_position
	rotation = heading


func _physics_process(delta: float) -> void:
	if track == null:
		return
	if driving_enabled:
		driver.drive(physics, track)
	else:
		physics.throttle = 0.0
		physics.brake = 0.0
		physics.steer = 0.0
		physics.handbrake = false
	physics.surface = CarPhysics.Surface.ROAD if track.is_on_track(physics.position) else CarPhysics.Surface.GRASS
	physics.step(delta)
	position = physics.position
	rotation = physics.heading


func _draw() -> void:
	draw_colored_polygon(PackedVector2Array(BODY), color)
