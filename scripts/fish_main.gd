class_name FishMain
extends Node3D
## Hauptszene der Fischphase (scenes/fish.tscn): eine 3D-Unterwasserwelt. Alle Knoten entstehen im Code.
## Koordinaten und Maße stehen in FishWorld (Meter, y nach oben).

## Reichweite des Mauls beim Fressen in Metern (wächst mit der Größe des Fischs).
const MOUTH_REACH := 0.5
const SAFE_RADIUS := 25.0 ## Raubfische in diesem Umkreis (Meter) verschwinden beim Wiedereinstieg.

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
var fishes: Array[AiFish] = []
var player_health := CellHealth.new(100.0)
var deaths := 0
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
	apply_sight()

	reef = ReefView.new()
	reef.name = "Reef"
	world.add_child(reef)
	food.spawn_around(FishWorld.START, 60, 5.0, 60.0, 0.3)
	food_view = FishFoodView.new()
	food_view.name = "Food"
	food_view.field = food
	world.add_child(food_view)
	spawn_fish()
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


## Nebeldichte zur Sichtweite: 0,025 bei 25 m (Anfang), dünner bei größerer Sicht.
static func fog_density_for(sight: float) -> float:
	return 0.025 * 25.0 / maxf(sight, 1.0)


## Stellt den Nebel passend zu den Augen des Fischs ein.
func apply_sight() -> void:
	water.environment.fog_density = fog_density_for(FishAbilities.sight(player.build))


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("entwickeln"):
		toggle_evolve()
	if evolve.visible:
		return
	player.drive(FishInput.read(), delta)
	think_fish(delta)
	player_bites()
	predators_bite()
	player_health.tick(delta)
	hud.show_health(player_health.ratio())
	check_death()
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
		eat_value(item["value"])
	hud.show_progress(progress)


## Rechnet einen Bissen Nahrung an; wächst der Fisch dabei, wird er größer.
func eat_value(value: int) -> void:
	if progress.eat(value):
		player.set_size(progress.size())
		hud.show_message("Dein Fisch ist gewachsen!")


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
	apply_sight()


## Verteilt die KI-Fische um den Spielerfisch.
func spawn_fish() -> void:
	for entry in FishSchool.spawn_plan(player.motion.position, 7):
		add_fish(entry["id"], entry["position"])


func add_fish(id: String, pos: Vector3) -> AiFish:
	var f := AiFish.new()
	f.setup(id, pos)
	world.add_child(f)
	fishes.append(f)
	return f


func remove_fish(f: AiFish) -> void:
	fishes.erase(f)
	f.queue_free()


## Alle KI-Fische entscheiden und schwimmen; Silberlinge halten sich an ihren Schwarm.
func think_fish(delta: float) -> void:
	var center: Variant = FishSchool.flock_center(fishes, "silberling")
	for f in fishes:
		f.think(delta, player.motion.position, player.size, center if f.species_id == "silberling" else null)


## Fleisch- und Allesfresser beißen Fische, die ihr Maul berührt; besiegte Fische werden gefressen.
func player_bites() -> void:
	if player.build.diet == Diet.PFLANZENFRESSER:
		return
	for f in fishes.duplicate():
		if FishCombat.bite_hits(player.mouth_point(), f.motion.position, f.radius()):
			if f.health.damage(FishAbilities.bite_damage(player.build)) and f.health.is_dead():
				remove_fish(f)
				eat_value(int(FishSpecies.data(f.species_id)["food"]))
				hud.show_progress(progress)
				hud.show_message("%s gefressen!" % FishSpecies.data(f.species_id)["name"])


## Raubfische beißen, wenn ihr Maul den Spielerfisch berührt; Stacheln wehren ab und verletzen sie.
func predators_bite() -> void:
	for f in fishes.duplicate():
		if not FishSpecies.is_predator(f.species_id):
			continue
		if FishCombat.bite_hits(f.mouth_point(), player.motion.position, 0.5 * player.size):
			var raw := float(FishSpecies.data(f.species_id)["bite"])
			if player_health.damage(FishCombat.damage_to_player(raw, player.build)):
				f.health.damage(FishCombat.spike_reflect(player.build))
				if f.health.is_dead():
					remove_fish(f)

## Nach dem Tod taucht der Fisch an der Startstelle wieder auf: DNA, Größe und Ausbau bleiben.
func check_death() -> void:
	if not player_health.is_dead():
		return
	deaths += 1
	player.motion.position = FishWorld.START
	player.motion.velocity = Vector3.ZERO
	player.sync()
	for f in fishes.duplicate():
		if FishSpecies.is_predator(f.species_id) and f.motion.position.distance_to(FishWorld.START) < SAFE_RADIUS:
			remove_fish(f)
	player_health.reset(2.0)
	hud.show_health(player_health.ratio())
	hud.show_message("Dein Fisch wurde gefressen und schwimmt neu los.")
