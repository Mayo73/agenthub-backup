class_name FishMain
extends Node3D
## Hauptszene der Fischphase (scenes/fish.tscn): eine 3D-Unterwasserwelt. Alle Knoten entstehen im Code.
## Koordinaten und Maße stehen in FishWorld (Meter, y nach oben).

## Spielwelt: Boden, Oberfläche, Pflanzen, Fische und Nahrung kommen hier hinein.
var world: Node3D
var camera: Camera3D
var sun: DirectionalLight3D
var water: WorldEnvironment
var floor_mesh: MeshInstance3D
var surface_mesh: MeshInstance3D
var player: FishPlayer
var reef: ReefView
var snow: MarineSnow
var hud: FishHud
var intro: FishIntro
var progress := FishProgress.new()


func _ready() -> void:
	Controls.setup()
	world = Node3D.new()
	world.name = "World"
	add_child(world)

	water = WorldEnvironment.new()
	water.name = "Water"
	water.environment = make_environment()
	add_child(water)

	sun = DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-60.0, 30.0, 0.0)
	sun.light_color = Color(0.75, 0.9, 1.0)
	add_child(sun)

	floor_mesh = make_plane("Floor", -FishWorld.DEPTH, FishWorld.FLOOR_COLOR)
	world.add_child(floor_mesh)
	surface_mesh = make_plane("Surface", 0.0, FishWorld.SURFACE_COLOR)
	world.add_child(surface_mesh)

	camera = Camera3D.new()
	camera.name = "Camera"
	camera.far = 400.0
	add_child(camera)
	player = FishPlayer.new()
	player.name = "Player"
	world.add_child(player)
	if FishStart.pending_build != null:
		player.set_build(FishStart.pending_build)
	progress.dna = FishStart.pending_dna
	FishStart.clear()

	reef = ReefView.new()
	reef.name = "Reef"
	world.add_child(reef)
	snow = MarineSnow.new()
	snow.name = "Snow"
	add_child(snow)
	hud = FishHud.new()
	hud.name = "Hud"
	add_child(hud)
	hud.show_progress(progress)
	intro = FishIntro.new()
	intro.name = "Intro"
	add_child(intro)
	intro.open(player.build)

	camera.position = ChaseCamera.target_position(player.motion.position, player.motion.yaw, player.size)
	camera.look_at(player.motion.position)
	camera.current = true


## Tiefblaues Wasser mit Nebel: Die Ferne verschwimmt wie unter Wasser.
static func make_environment() -> Environment:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = FishWorld.WATER_COLOR
	env.ambient_light_source = 0
	env.ambient_light_color = Color(0.45, 0.65, 0.75)
	env.ambient_light_energy = 0.7
	env.fog_enabled = true
	env.fog_light_color = FishWorld.WATER_COLOR
	env.fog_density = 0.025
	return env


## Waagrechte Fläche über die ganze Welt (Boden oder Wasseroberfläche), von beiden Seiten sichtbar.
static func make_plane(node_name: String, y: float, color: Color) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = Vector3(FishWorld.HALF_SIZE * 2.0, 0.1, FishWorld.HALF_SIZE * 2.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	if color.a < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var m := MeshInstance3D.new()
	m.name = node_name
	m.mesh = box
	m.material_override = mat
	m.position = Vector3(0.0, y, 0.0)
	return m


func _physics_process(delta: float) -> void:
	player.drive(FishInput.read(), delta)
	hud.show_depth(player.motion.depth())


## Kamera folgt weich und schaut auf den Fisch; die Schwebeteilchen bleiben bei der Kamera.
func _process(delta: float) -> void:
	var target := ChaseCamera.target_position(player.motion.position, player.motion.yaw, player.size)
	camera.position = ChaseCamera.follow(camera.position, target, delta)
	camera.look_at(player.motion.position)
	snow.position = camera.position
