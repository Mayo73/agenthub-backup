extends Node2D
## Das Auto in der Spielwelt: liest die Eingaben, rechnet die Fahrphysik und zeigt das Ergebnis.
## Liegt unter "World" (isometrisch projiziert) und arbeitet deshalb in Weltkoordinaten.

signal respawned

## Liegt das Auto weiter als so viel neben der Strecke, wird es automatisch zurückgesetzt.
const MAX_OFFTRACK := 500.0

var physics := CarPhysics.new()
var track: TrackPath
var input_enabled := true
var smoke: CPUParticles2D
var car_id := CarCatalog.DEFAULT_ID
## Eigener Motor ohne Entfernungsdämpfung (die Kamera schaut voraus, der Klang soll trotzdem nah bleiben).
var engine_player: AudioStreamPlayer
var squeal_player: AudioStreamPlayer
var sprite: Sprite2D


func _ready() -> void:
	Controls.setup()
	smoke = CPUParticles2D.new()
	smoke.name = "Smoke"
	smoke.position = Vector2(-20, 0)
	smoke.emitting = false
	smoke.amount = 40
	smoke.lifetime = 0.9
	smoke.local_coords = false
	smoke.direction = Vector2(-1, 0)
	smoke.spread = 35.0
	smoke.initial_velocity_min = 20.0
	smoke.initial_velocity_max = 60.0
	smoke.gravity = Vector2.ZERO
	smoke.scale_amount_min = 6.0
	smoke.scale_amount_max = 12.0
	smoke.color = Color(0.85, 0.85, 0.85, 0.35)
	add_child(smoke)
	move_child(smoke, 0)

	engine_player = AudioStreamPlayer.new()
	engine_player.name = "Engine"
	engine_player.stream = SoundBank.engine_loop()
	engine_player.volume_db = EngineAudio.engine_db(0.0)
	engine_player.pitch_scale = EngineAudio.pitch_for(0.0, physics.max_speed)
	add_child(engine_player)
	engine_player.play()

	squeal_player = AudioStreamPlayer.new()
	squeal_player.name = "Squeal"
	squeal_player.stream = SoundBank.squeal_loop()
	squeal_player.volume_db = EngineAudio.SILENT_DB
	add_child(squeal_player)
	squeal_player.play()

	apply_skin(car_id)


func _physics_process(delta: float) -> void:
	if input_enabled:
		physics.throttle = Input.get_action_strength("gas")
		physics.brake = Input.get_action_strength("bremse")
		physics.steer = Input.get_axis("links", "rechts")
		physics.handbrake = Input.is_action_pressed("handbremse")
	else:
		physics.throttle = 0.0
		physics.brake = 0.0
		physics.steer = 0.0
		physics.handbrake = false
	if track:
		var on_track := track.is_on_track(physics.position)
		physics.surface = CarPhysics.Surface.ROAD if on_track else CarPhysics.Surface.GRASS
	physics.step(delta)
	if smoke:
		smoke.emitting = physics.is_drifting()
	if track and (Input.is_action_just_pressed("zuruecksetzen")
			or track.distance_from_center(physics.position) > track.width * 0.5 + MAX_OFFTRACK):
		respawn()
	position = physics.position
	rotation = physics.heading
	update_sound()


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


## Übernimmt Abstimmung und Farbe eines Autos aus dem CarCatalog. Unbekannte IDs werden ignoriert.
func apply_car(id: String) -> void:
	if not CarCatalog.has_car(id):
		return
	car_id = id
	var fresh := CarPhysics.new()
	fresh.position = physics.position
	fresh.heading = physics.heading
	physics = fresh
	CarCatalog.apply(id, physics)
	var body := get_node_or_null("Body") as Polygon2D
	if body:
		body.color = CarCatalog.color_of(id)
	var roof := get_node_or_null("Roof") as Polygon2D
	if roof:
		roof.color = CarCatalog.color_of(id).darkened(0.3)
	apply_skin(id)


## Zeigt das Bild des Autos. Ohne Bild bleiben die Polygone sichtbar.
func apply_skin(id: String) -> void:
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.name = "Sprite"
		sprite.scale = Vector2(0.5, 0.5)
		add_child(sprite)
	var path := CarCatalog.sprite_of(id)
	sprite.texture = load(path) as Texture2D if path != "" else null
	for part in ["Body", "Roof", "Windshield", "Headlights", "Headlights2"]:
		var node := get_node_or_null(part) as CanvasItem
		if node:
			node.visible = sprite.texture == null


## Passt die Motorklänge an den Fahrzustand an.
func update_sound() -> void:
	if engine_player == null:
		return
	engine_player.pitch_scale = EngineAudio.pitch_for(physics.speed(), physics.max_speed)
	engine_player.volume_db = EngineAudio.engine_db(physics.throttle)
	if squeal_player:
		squeal_player.volume_db = EngineAudio.squeal_db(physics.is_drifting(), physics.slip_angle_deg())
