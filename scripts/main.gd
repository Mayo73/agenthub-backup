extends Node2D
## Hauptszene der Zellenphase. Verdrahtet Spielerzelle, Nahrung, KI-Zellen, Kamera und HUD.
## Die Logik steckt in RefCounted-Klassen unter scripts/, hier nur Verdrahtung.

const MOUTH_REACH := 4.0
const RESPAWN_INVULNERABLE := 2.0

@onready var world: Node2D = $World
@onready var camera: Camera2D = $Camera

var player: PlayerCell
var progress := CellProgress.new()
var food := FoodField.new(7)
var food_view: FoodView
var hud: Hud
var spawner := EcoSpawner.new(11)
var ai_cells: Array[AiCell] = []
var player_health := CellHealth.new()
var deaths := 0
var backdrop: WaterBackdrop
var unlocks: PartUnlocks = PartUnlocks.new()
var pickups: PartPickups = PartPickups.new(13)
var pickup_view: PickupView
var poison := PoisonClouds.new()
var electric := ElectricOrgan.new()


func _ready() -> void:
	Controls.setup()
	player = PlayerCell.new()
	player.name = "Player"
	world.add_child(player)
	camera.zoom = Vector2.ONE * CameraZoom.target_for_radius(player.radius)
	food.spawn_around(Vector2.ZERO, 60, 60.0, 900.0, 0.3)
	food_view = FoodView.new()
	food_view.name = "Food"
	food_view.field = food
	world.add_child(food_view)
	world.move_child(food_view, 0)
	hud = Hud.new()
	hud.name = "Hud"
	add_child(hud)
	hud.show_progress(progress)
	backdrop = WaterBackdrop.new()
	backdrop.name = "Backdrop"
	backdrop.camera = camera
	world.add_child(backdrop)
	world.move_child(backdrop, 0)
	pickup_view = PickupView.new()
	pickup_view.name = "Pickups"
	pickup_view.pickups = pickups
	world.add_child(pickup_view)


func _physics_process(delta: float) -> void:
	player_health.tick(delta)
	feed_player()
	refill_food()
	collect_pickups()
	spawn_ai()
	despawn_far_ai()
	think_ai()
	feed_ai()
	resolve_weapons(delta)
	resolve_combat()
	check_death()


## Frisst alles, was das Maul der Spielerzelle berührt und zur Ernährung passt.
func feed_player() -> void:
	for item in food.take_at(player.mouth_point(), MOUTH_REACH, player.diet):
		if progress.eat(item.value):
			player.set_stage(progress.stage)


## Entfernt weit entfernte Nahrung und streut neue um den Spieler, wenn sie knapp wird.
func refill_food() -> void:
	food.remove_far(player.position, 1400.0)
	if food.items.size() < 40:
		food.spawn_around(player.position, 20, 500.0, 1200.0, 0.3)


func _process(delta: float) -> void:
	camera.position = player.position
	var zoom := CameraZoom.smooth(camera.zoom.x, CameraZoom.target_for_radius(player.radius), delta)
	camera.zoom = Vector2(zoom, zoom)
	hud.show_progress(progress)
	hud.show_health(player_health)


## Füllt die KI-Zellen auf EcoSpawner.TARGET_COUNT auf.
func spawn_ai() -> void:
	var spread := EcoSpawner.view_scale(player.radius)
	for i in EcoSpawner.missing(ai_cells.size()):
		var cell := AiCell.new()
		cell.setup(spawner.pick_species(progress.stage), spawner.spawn_position(player.position, spread))
		world.add_child(cell)
		ai_cells.append(cell)


func remove_ai(cell: AiCell) -> void:
	ai_cells.erase(cell)
	world.remove_child(cell)
	cell.queue_free()


func despawn_far_ai() -> void:
	var spread := EcoSpawner.view_scale(player.radius)
	for cell in ai_cells.duplicate():
		if EcoSpawner.is_too_far(player.position, cell.position, spread):
			remove_ai(cell)


## Jede KI-Zelle entscheidet anhand aller Zellen (Spieler eingeschlossen) und der nächsten Nahrung.
func think_ai() -> void:
	var infos: Array = [{"position": player.position, "radius": player.radius, "diet": player.diet}]
	for cell in ai_cells:
		infos.append(cell.info())
	for cell in ai_cells:
		var kind := Diet.FLEISCH if cell.diet == Diet.FLEISCHFRESSER else Diet.PFLANZE
		var item = food.nearest(cell.position, kind, cell.brain.sight)
		cell.think(infos, item.position if item != null else null)


func feed_ai() -> void:
	for cell in ai_cells:
		food.take_at(cell.mouth_point(), MOUTH_REACH, cell.diet)


## Bisse zwischen Spieler und KI-Zellen; besiegte KI-Zellen werden zu Fleisch.
func resolve_combat() -> void:
	for cell in ai_cells.duplicate():
		if CombatRules.can_bite(player.diet) and CombatRules.bite_hits(player.motion.position, player.motion.heading, player.radius, cell.motion.position, cell.radius):
			if cell.health.damage(CombatRules.bite_damage(CombatRules.PLAYER_BITE, player.radius, cell.radius)):
				cell.motion.knockback(cell.motion.position - player.motion.position, 120.0)
		if cell.damage > 0.0 and CombatRules.can_bite(cell.diet) and CombatRules.bite_hits(cell.motion.position, cell.motion.heading, cell.radius, player.motion.position, player.radius):
			if player_health.damage(CombatRules.bite_damage(cell.damage, cell.radius, player.radius)):
				player.motion.knockback(player.motion.position - cell.motion.position, 160.0)
		if cell.health.is_dead():
			for pos in CombatRules.meat_positions(cell.motion.position, cell.radius):
				food.add_item(Diet.FLEISCH, pos)
			remove_ai(cell)


## Nach dem Tod schlüpft eine neue Zelle: DNA und Größe bleiben, nahe KI-Zellen verschwinden.
func check_death() -> void:
	if not player_health.is_dead():
		return
	deaths += 1
	player_health.reset(RESPAWN_INVULNERABLE)
	player.motion.velocity = Vector2.ZERO
	var clear_dist := 400.0 * EcoSpawner.view_scale(player.radius)
	for cell in ai_cells.duplicate():
		if cell.position.distance_to(player.position) < clear_dist:
			remove_ai(cell)
	hud.show_message("Deine Zelle wurde gefressen – eine neue schlüpft.")


## Hält einen Teilefund in der Nähe bereit, solange noch Teile gesperrt sind.
## Berühren schaltet das nächste Teil frei.
func collect_pickups() -> void:
	var spread := EcoSpawner.view_scale(player.radius)
	pickups.remove_far(player.position, 2000.0 * spread)
	if pickups.positions.is_empty() and not unlocks.all_unlocked():
		pickups.spawn_around(player.position, 600.0 * spread, 1200.0 * spread)
	var count := pickups.take_touching(player.position, player.radius)
	for _i in count:
		var id = unlocks.next_locked()
		if unlocks.unlock(id):
			hud.show_message("Neues Teil gefunden: %s" % PartCatalog.name_of(id))


## Stacheln, Gift und Elektroorgan der Spielerzelle gegen KI-Zellen.
func resolve_weapons(delta: float) -> void:
	var pos := player.motion.position
	var heading := player.motion.heading
	var tips := WeaponRules.spike_tips(pos, heading, player.radius, player.build)
	poison.tick(delta)
	electric.tick(delta)
	if player.build.count("gift") > 0 and player.motion.speed() > 20.0:
		poison.emit(PartGeometry.world_point(pos, heading, player.radius, Vector2(-1.2, 0)))
	var zap := player.build.count("elektro") > 0 and electric.is_ready()
	var zapped := false
	for cell in ai_cells:
		if WeaponRules.spike_hits(tips, cell.motion.position, cell.radius) > 0:
			if cell.health.damage(WeaponRules.SPIKE_DAMAGE):
				cell.motion.knockback(cell.motion.position - pos, 100.0)
		cell.health.drain(poison.damage_at(cell.motion.position, cell.radius, delta))
		if zap and ElectricOrgan.in_range(pos, player.radius, cell.motion.position, cell.radius):
			cell.health.damage(ElectricOrgan.DAMAGE)
			zapped = true
	if zapped:
		electric.fire()
