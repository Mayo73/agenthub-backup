class_name FishMain
extends Node3D
## Hauptszene der Fischphase (scenes/fish.tscn): eine 3D-Unterwasserwelt. Alle Knoten entstehen im Code.
## Koordinaten und Maße stehen in FishWorld (Meter, y nach oben).

## Reichweite des Mauls beim Fressen in Metern (wächst mit der Größe des Fischs).
const MOUTH_REACH := 0.5

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
var evolve: EvolveMenu
var progress := FishProgress.new()
var food := FishFood.new()
var food_view: FishFoodView


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
	food.spawn_around(FishWorld.START, 60, 5.0, 60.0, 0.3)
	food_view = FishFoodView.new()
	food_view.name = "Food"
	food_view.field = food
	world.add_child(food_view)
	snow = MarineSnow.new()
	snow.name = "Snow"
	add_child(snow)
	hud = FishHud.new()
	hud.name = "Hud"
	add_child(hud)
	hud.show_progress(progress)
	evolve = EvolveMenu.new()
	evolve.name = "Evolve"
	add_child(evolve)
	evolve.upgraded.connect(_on_upgraded)
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
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.45, 0.65, 0.75)
	env.ambient_light_energy = 0.7
	env.fog_enabled = true
	env.fog_light_color = FishWorld.WATER_COLOR
	env.fog_density = 0.025
	return env


## Waagrechte Fläche über die ganze Welt (Boden oder Wasseroberfläche), von beiden Seiten sichtbar.
static func make_plane(node_name: String, y: float, color: Color) -> MeshInstance3D:
	var plane := PlaneMesh.new()
	plane.size = Vector2.ONE * FishWorld.HALF_SIZE * 2.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	if color.a < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	plane.material = mat
	var m := MeshInstance3D.new()
	m.name = node_name
	m.mesh = plane
	m.position = Vector3(0.0, y, 0.0)
	return m


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("entwickeln"):
		toggle_evolve()
	if evolve.visible:
		return
	player.drive(FishInput.read(), delta)
	hud.show_depth(player.motion.depth())
	feed_player()
	refill_food()


## Kamera folgt weich und schaut auf den Fisch; die Schwebeteilchen bleiben bei der Kamera.
func _process(delta: float) -> void:
	var target := ChaseCamera.target_position(player.motion.position, player.motion.yaw, player.size)
	camera.position = ChaseCamera.follow(camera.position, target, delta)
	camera.look_at(player.motion.position)
	snow.position = camera.position


## Frisst, was das Maul berührt und zur Ernährung passt. Wächst der Fisch, wird er größer.
func feed_player() -> void:
	for item in food.take_at(player.mouth_point(), MOUTH_REACH * player.size, player.build.diet):
		if progress.eat(item["value"]):
			player.set_size(progress.size())
			hud.show_message("Dein Fisch ist gewachsen!")
	hud.show_progress(progress)


## Entfernt weit entfernte Nahrung und streut neue um den Fisch, wenn sie knapp wird.
func refill_food() -> void:
	food.remove_far(player.motion.position, 90.0)
	if food.items.size() < 40:
		food.spawn_around(player.motion.position, 20, 15.0, 70.0, 0.3)


## Öffnet oder schließt das Entwicklungsmenü.
func toggle_evolve() -> void:
	if evolve.visible:
		evolve.close()
	else:
		evolve.open(player.build, progress)


## Nach einer Verbesserung: Aussehen und Fähigkeiten neu, Anzeige aktualisieren.
func _on_upgraded(slot: String) -> void:
	player.set_build(player.build)
	hud.show_progress(progress)
	hud.show_message("%s verbessert!" % FishBuild.NAMES[slot])
