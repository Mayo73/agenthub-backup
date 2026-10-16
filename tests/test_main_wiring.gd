extends "res://tests/base_test.gd"


var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()


func test_grundknoten() -> void:
	check(main.world is Node2D, "World ist ein Node2D")
	check(main.camera is Camera2D, "Camera ist eine Camera2D")


func test_spieler() -> void:
	check(main.player is PlayerCell, "main.player ist ein PlayerCell")
	check(main.player.get_parent() == main.world, "main.player.parent == main.world")
	main.player.drive(0.1, Vector2.RIGHT)
	main._process(0.016)
	check_eq(main.camera.position.x, main.player.position.x, "camera x folgt player")
	check_eq(main.camera.position.y, main.player.position.y, "camera y folgt player")


func test_kamera_zoom() -> void:
	check_eq(main.camera.zoom.x, 1.6, "Anfangs-Zoom ist 1.6 für Radius 12.0")
	main.player.radius = 24.0
	main._process(100.0)
	check_eq(main.camera.zoom.x, 0.8, "Nach Wachstum auf Radius 24.0 ist Zoom 0.8")


func test_nahrung_angelegt() -> void:
	check_eq(main.food.items.size(), 60, "main.food.items.size() ist 60")
	check(main.food_view.field == main.food, "main.food_view.field == main.food ist wahr")
	check_eq(main.food_view.get_index(), 0, "main.food_view.get_index() ist 0")


func test_pflanze_fressen() -> void:
	main.food.items.clear()
	main.food.add_item(Diet.PFLANZE, main.player.mouth_point())
	main.feed_player()
	check_eq(main.progress.dna, 1, "main.progress.dna ist 1")
	check_eq(main.food.items.size(), 0, "main.food.items.size() ist 0")


func test_fleisch_nicht_fressen() -> void:
	main.food.items.clear()
	main.food.add_item(Diet.FLEISCH, main.player.mouth_point())
	main.feed_player()
	check_eq(main.progress.dna, 0, "main.progress.dna ist 0")
	check_eq(main.progress.growth, 0, "main.progress.growth ist 0")
	check_eq(main.food.items.size(), 1, "main.food.items.size() ist 1")


func test_nachfuellen() -> void:
	main.food.items.clear()
	main.refill_food()
	check_eq(main.food.items.size(), 20, "main.food.items.size() ist 20")


func test_hud() -> void:
	check(main.hud is Hud, "main.hud ist ein Hud")
	main.progress.eat(3)
	main._process(0.016)
	check_eq(main.hud.dna_label.text, "DNA: 3", "hud zeigt DNA nach Fressen")


func test_wachsen_beim_fressen() -> void:
	main.food.items.clear()
	main.progress.eat(9)
	main.food.add_item(Diet.PFLANZE, main.player.mouth_point())
	main.feed_player()
	check_eq(main.progress.stage, 1, "main.progress.stage ist 1")
	check_eq(main.player.radius, 18.0, "main.player.radius ist 18.0")


func test_ki_zellen() -> void:
	# Main muss bereit sein, damit progress.stage verfügbar ist
	main._physics_process(0.016)
	main.spawn_ai()
	check_eq(main.ai_cells.size(), 30, "main.ai_cells.size() ist 30 nach spawn_ai")
	check(main.ai_cells[0].get_parent() == main.world, "main.ai_cells[0].get_parent() == main.world")
	var count: int = main.ai_cells.size()
	main.spawn_ai()
	check_eq(main.ai_cells.size(), count, "weiterhin 30 Zellen nach erneutem spawn_ai")


func test_ki_entfernen() -> void:
	main._physics_process(0.016)
	main.spawn_ai()
	var size: int = main.ai_cells.size()
	main.ai_cells[0].position = Vector2(99999, 0)
	main.despawn_far_ai()
	check_eq(main.ai_cells.size(), size - 1, "main.ai_cells.size() ist 29 nach despawn_far_ai")


func test_ki_entscheidet() -> void:
	main._physics_process(0.016)
	main.spawn_ai()
	main.think_ai()
	for cell in main.ai_cells:
		check(cell.brain.state in [AiBrain.SUCHEN, AiBrain.JAGEN, AiBrain.FLIEHEN, AiBrain.TREIBEN], "cell.brain.state ist ein gültiger Zustand")


func test_ki_frisst() -> void:
	main.food.items.clear()
	var cell := AiCell.new()
	cell.setup("blasenling", Vector2(300, 0))
	main.world.add_child(cell)
	main.ai_cells.append(cell)
	main.food.add_item(Diet.PFLANZE, cell.mouth_point())
	main.feed_ai()
	check_eq(main.food.items.size(), 0, "main.food.items.size() ist 0 nach feed_ai")


func _add_ai(id: String, pos: Vector2, heading: float) -> AiCell:
	var cell := AiCell.new()
	cell.setup(id, pos)
	cell.motion.heading = heading
	main.world.add_child(cell)
	main.ai_cells.append(cell)
	return cell


func test_spieler_beisst() -> void:
	main.player.diet = Diet.FLEISCHFRESSER
	var meat_before: int = main.food.count_kind(Diet.FLEISCH)
	_add_ai("blasenling", Vector2(20, 0), 0.0)
	main.resolve_combat()
	check_eq(main.ai_cells.size(), 0, "main.ai_cells.size() ist 0")
	check_eq(main.food.count_kind(Diet.FLEISCH), meat_before + 3, "main.food.count_kind(Diet.FLEISCH) ist meat_before + 3")


func test_pflanzenfresser_beisst_nicht() -> void:
	var cell := _add_ai("blasenling", Vector2(20, 0), 0.0)
	main.resolve_combat()
	check_eq(cell.health.hp, 20.0, "cell.health.hp ist 20.0")
	check_eq(main.ai_cells.size(), 1, "main.ai_cells.size() ist 1")


func test_ki_beisst() -> void:
	_add_ai("schnapper", Vector2(30, 0), PI)
	main.resolve_combat()
	check_eq(main.player_health.hp, 77.5, "main.player_health.hp ist 77.5")


func test_ki_von_hinten_harmlos() -> void:
	_add_ai("schnapper", Vector2(30, 0), 0.0)
	main.resolve_combat()
	check_eq(main.player_health.hp, 100.0, "main.player_health.hp ist 100.0")


func test_tod() -> void:
	main.progress.eat(5)
	main.player_health.hp = 0.0
	main.check_death()
	check_eq(main.deaths, 1, "main.deaths ist 1 nach check_death")
	check_eq(main.player_health.hp, 100.0, "main.player_health.hp ist 100.0 nach Tod")
	check_eq(main.player_health.invulnerable, 2.0, "main.player_health.invulnerable ist 2.0")
	check_eq(main.progress.dna, 5, "main.progress.dna ist 5 (bleibt)")
	check(main.hud.message_label.text != "", "message_label hat Text nach Tod")


func test_tod_vertreibt_gegner() -> void:
	var cell := AiCell.new()
	cell.setup("schnapper", Vector2(50, 0))
	main.world.add_child(cell)
	main.ai_cells.append(cell)
	main.player_health.hp = 0.0
	main.check_death()
	check_eq(main.ai_cells.size(), 0, "main.ai_cells.size() ist 0 nach check_death")


func test_lebend_nichts() -> void:
	main.check_death()
	check_eq(main.deaths, 0, "main.deaths ist 0 wenn nicht tot")


func test_hintergrund() -> void:
	check(main.backdrop is WaterBackdrop, "main.backdrop is WaterBackdrop wahr")
	check_eq(main.backdrop.get_index(), 2, "main.backdrop.get_index() ist 2")
	check(main.backdrop.camera == main.camera, "main.backdrop.camera == main.camera wahr")
