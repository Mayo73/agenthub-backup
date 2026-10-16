extends Node2D
## KI-Gegner: fährt mit AiDriver und CarPhysics, zeichnet sich als einfaches Auto.
## Liegt unter "World" und arbeitet in Weltkoordinaten.

const BODY := [Vector2(-25, -12), Vector2(21, -12), Vector2(26, -7), Vector2(26, 7), Vector2(21, 12), Vector2(-25, 12)]

var physics := CarPhysics.new()
var driver := AiDriver.new()
var track: TrackPath
var lap_timer: LapTimer
var color := Color(0.55, 0.3, 0.8)
var car_id := ""
var texture: Texture2D
var driving_enabled := false
var engine_player: AudioStreamPlayer2D


func _init() -> void:
	scale = Vector2(1.3, 1.3)


func _ready() -> void:
	engine_player = AudioStreamPlayer2D.new()
	engine_player.name = "Engine"
	engine_player.stream = SoundBank.engine_loop()
	engine_player.volume_db = -12.0
	engine_player.max_distance = 1500.0
	add_child(engine_player)
	engine_player.play()


## Setzt das Auto still an eine Stelle.
func place_at(world_position: Vector2, heading: float) -> void:
	physics.position = world_position
	physics.heading = heading
	physics.velocity = Vector2.ZERO
	physics.sliding = false
	position = world_position
	rotation = heading
	lap_timer = LapTimer.new(track.length) if track else null


## Wählt das Auto (Bild) aus dem CarCatalog. Unbekannte IDs werden ignoriert.
func set_car(id: String) -> void:
	if not CarCatalog.has_car(id):
		return
	car_id = id
	texture = load(CarCatalog.sprite_of(id)) as Texture2D
	queue_redraw()


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
	if driving_enabled and lap_timer:
		lap_timer.update(delta, track.progress_at(physics.position))
	if engine_player:
		engine_player.pitch_scale = EngineAudio.pitch_for(physics.speed(), physics.max_speed)


## Insgesamt gefahrene Strecke (für die Platzierung).
func race_distance() -> float:
	return lap_timer.distance() if lap_timer else 0.0


func _draw() -> void:
	var shadow := PackedVector2Array()
	for p in BODY:
		shadow.append(p + Vector2(5, 5))
	draw_colored_polygon(shadow, Color(0, 0, 0, 0.35))
	if texture:
		draw_texture_rect(texture, Rect2(-26, -12, 52, 24), false)
	else:
		draw_colored_polygon(PackedVector2Array(BODY), color)
