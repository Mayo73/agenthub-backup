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
var mate := MateCall.new()
var partner_view: PartnerView
var editor_open := false
var editor: CellEditor
var save_path := SaveGame.DEFAULT_PATH
## Erst nach start_new() oder load_saved() wird automatisch gespeichert.
var autosave := false
var main_menu: MainMenu
var pause_menu: PauseMenu
var in_menu := false
var paused := false
var settings := UserSettings.new()
var settings_path := UserSettings.DEFAULT_PATH
var settings_menu: SettingsMenu
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
	pickup_view = PickupView.new()
	pickup_view.name = "Pickups"
	pickup_view.pickups = pickups
	world.add_child(pickup_view)
	partner_view = PartnerView.new()
	partner_view.name = "Partner"
	world.add_child(partner_view)
	main_menu = MainMenu.new()
	main_menu.name = "MainMenu"
	add_child(main_menu)
	main_menu.set_can_continue(FileAccess.file_exists(save_path))
	main_menu.new_game.connect(_on_new_game)
	main_menu.continue_game.connect(_on_continue)
	main_menu.quit_game.connect(quit)
	pause_menu = PauseMenu.new()
	pause_menu.name = "PauseMenu"
	add_child(pause_menu)
	pause_menu.resume.connect(toggle_pause)
	pause_menu.to_main_menu.connect(back_to_menu)
	pause_menu.quit_game.connect(quit)
	settings.load_from(settings_path)
	settings_menu = SettingsMenu.new()
	settings_menu.name = "SettingsMenu"
	add_child(settings_menu)
	main_menu.open_settings.connect(open_settings)
	pause_menu.open_settings.connect(open_settings)
	settings_menu.closed.connect(close_settings)
	apply_settings()
	show_menu(true)


func _physics_process(delta: float) -> void:
	if editor_open:
		return
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
	update_mate()


## Frisst alles, was das Maul der Spielerzelle berührt und zur Ernährung passt.
func feed_player() -> void:
	for item in food.take_at(player.mouth_point(), MOUTH_REACH, player.diet):
		if progress.eat(item.value):
			player.set_stage(progress.stage)
			mate.add_charge()
			hud.show_message("Neuer Ruf bereit: Taste C oder rechte Maustaste")
			autosave_now()


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
			var part := PartDrops.drop_for(cell.species_id, unlocks)
			if part != "" and unlocks.unlock(part):
				hud.show_message("Teil erbeutet: %s" % PartCatalog.name_of(part))
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


## Ruf auslösen, beim Erreichen des Partners den Zelleditor öffnen, Partner zeichnen.
func update_mate() -> void:
	if Input.is_action_just_pressed("rufen"):
		call_mate()
	if mate.reached(player.position, player.radius):
		open_editor()
	partner_view.partner_pos = mate.partner_pos


func call_mate() -> bool:
	if mate.call_partner(player.position, player.motion.heading):
		hud.show_message("Ein Partner antwortet – schwimm zu ihm!")
		return true
	return false


## Öffnet den Zelleditor; die Welt ist so lange verborgen und angehalten.
func open_editor() -> void:
	editor_open = true
	player.input_enabled = false
	mate.finish()
	world.visible = false
	hud.visible = false
	editor = CellEditor.new()
	editor.name = "Editor"
	add_child(editor)
	editor.open(player.build, unlocks, progress, progress.stage)
	editor.set_look(player.look)
	editor.finished.connect(close_editor)


## Übernimmt das Ergebnis des Editors und kehrt ins Spiel zurück.
func close_editor(build: CellBuild) -> void:
	player.set_build(build)
	if editor.confirmed:
		player.set_look(editor.look)
	remove_child(editor)
	editor.queue_free()
	editor = null
	world.visible = true
	hud.visible = true
	editor_open = false
	player.input_enabled = true
	hud.show_progress(progress)
	autosave_now()


## Neue Partie mit Startaufbau passend zur Ernährung (Pflanzen- oder Fleischfresser).
func start_new(diet: String) -> void:
	progress = CellProgress.new()
	player_health.reset()
	unlocks = PartUnlocks.new()
	mate = MateCall.new()
	player.diet = diet
	player.set_build(CellBuild.starter(diet))
	player.set_stage(0)
	player.set_look(CellLook.new())
	hud.show_progress(progress)
	autosave = true


func save_now() -> bool:
	var data := SaveGame.to_dict(progress, player_health, player.build, unlocks)
	data["look"] = player.look.to_dict()
	data["diet"] = player.diet
	return SaveGame.write_file(save_path, data)


func autosave_now() -> void:
	if autosave:
		save_now()


## Lädt den Spielstand; false, wenn keiner da ist oder er nicht passt.
func load_saved() -> bool:
	var data := SaveGame.read_file(save_path)
	if data.is_empty() or not SaveGame.apply(data, progress, player_health, unlocks):
		return false
	player.diet = str(data.get("diet", Diet.PFLANZENFRESSER))
	player.set_build(SaveGame.read_build(data))
	player.set_stage(progress.stage)
	var look_data: Variant = data.get("look")
	if look_data is Dictionary:
		player.set_look(CellLook.from_dict(look_data))
	hud.show_progress(progress)
	autosave = true
	return true


## Zeigt oder verbirgt das Hauptmenü; im Menü steht die Spielwelt still.
func show_menu(value: bool) -> void:
	in_menu = value
	main_menu.visible = value
	hud.visible = not value
	world.visible = not value
	set_physics_process(not value)
	world.process_mode = Node.PROCESS_MODE_DISABLED if value else Node.PROCESS_MODE_INHERIT


func _on_new_game(diet: String) -> void:
	start_new(diet)
	show_menu(false)


func _on_continue() -> void:
	if load_saved():
		show_menu(false)


## Esc im Spiel: Pause an oder aus. Im Hauptmenü und im Editor wirkungslos.
func toggle_pause() -> void:
	if in_menu or editor_open:
		return
	paused = not paused
	if paused:
		pause_menu.open()
	else:
		pause_menu.close()
	set_physics_process(not paused)
	world.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT


func back_to_menu() -> void:
	autosave_now()
	paused = false
	pause_menu.close()
	main_menu.set_can_continue(FileAccess.file_exists(save_path))
	show_menu(true)


func quit() -> void:
	autosave_now()
	get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()


func open_settings() -> void:
	settings_menu.show_settings(settings)


func close_settings() -> void:
	settings.save(settings_path)
	apply_settings()


## Wendet Lautstärken (Audiobusse "Musik" und "Effekte", falls vorhanden), Vollbild und Auflösung an.
func apply_settings() -> void:
	var music := AudioServer.get_bus_index("Musik")
	if music >= 0:
		AudioServer.set_bus_volume_db(music, UserSettings.to_db(settings.music_volume))
	var sfx := AudioServer.get_bus_index("Effekte")
	if sfx >= 0:
		AudioServer.set_bus_volume_db(sfx, UserSettings.to_db(settings.sfx_volume))
	if DisplayServer.get_name() == "headless":
		return
	if settings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(settings.resolution())

