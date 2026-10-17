extends "res://tests/base_test.gd"

const P := "user://test_abnahme_groesse.json"
var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	main.save_path = P
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()
	if FileAccess.file_exists(P):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(P))


func _eat_to_stage(kind: String, stage: int) -> void:
	for _i in range(500):
		if main.progress.stage >= stage:
			break
		main.food.items.clear()
		main.food.add_item(kind, main.player.mouth_point())
		main.feed_player()


func _clear_ai() -> void:
	for cell in main.ai_cells.duplicate():
		main.remove_ai(cell)


func _species() -> Array[String]:
	var result: Array[String] = []
	for cell in main.ai_cells:
		result.append(cell.species_id)
	return result


func test_fuenf_abschnitte() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	for s in range(1, 5):
		_eat_to_stage(Diet.PFLANZE, s)
		check_eq(main.progress.stage, s, "Schritt %d: stage ist %d" % [s, s])
		check_eq(main.player.radius, CellProgress.radius_for_stage(s), "Schritt %d: radius passt" % s)
		if s > 0:
			check(main.player.radius > CellProgress.radius_for_stage(s - 1), "radius wächst zwischen %d und %d" % [s - 1, s])


func test_kamera_zoomt_heraus() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	var last := 100.0
	for s in range(0, 5):
		_eat_to_stage(Diet.PFLANZE, s)
		for _j in range(3):
			main._process(10.0)
		var target := CameraZoom.target_for_radius(main.player.radius)
		check(absf(main.camera.zoom.x - target) < 0.01, "Schritt %d: Kamera zoomt auf Ziel" % s)
		check(main.camera.zoom.x < last, "Schritt %d: Zoom wird kleiner (herausgezoomt)" % s)
		last = main.camera.zoom.x


func test_begegnungen_wechseln() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	_clear_ai()
	main.spawn_ai()
	check(main.ai_cells.size() == EcoSpawner.TARGET_COUNT, "Anfangs genug KI-Zellen")
	for sid in _species():
		check(sid in SpeciesCatalog.ids_near_stage(0), "%s ist bei Stufe 0 erlaubt" % sid)
	_clear_ai()
	_eat_to_stage(Diet.PFLANZE, 4)
	main.spawn_ai()
	for sid in _species():
		check(sid in SpeciesCatalog.ids_near_stage(4), "%s ist bei Stufe 4 erlaubt" % sid)
	check(SpeciesCatalog.ids_near_stage(0) != SpeciesCatalog.ids_near_stage(4), "Artenschutzliste ändert sich zwischen Stufe 0 und 4")


func test_gefahr_wird_beute() -> void:
	main.start_new(Diet.FLEISCHFRESSER)
	var r := SpeciesCatalog.radius_of("schnapper")
	var d: String = SpeciesCatalog.data("schnapper")["diet"]
	check(AiBrain.is_threat(main.player.radius, r, d), "Schnapper ist zunächst Gefahr")
	_eat_to_stage(Diet.FLEISCH, 3)
	check(not AiBrain.is_threat(main.player.radius, r, d), "Schnapper wird keine Gefahr mehr")
	check(AiBrain.is_prey(main.player.radius, main.player.diet, r), "Schnapper wird zur Beute")
	_clear_ai()
	var cell := AiCell.new()
	var pos: Vector2 = main.player.motion.position + Vector2.from_angle(main.player.motion.heading) * (main.player.radius + r * 0.5)
	cell.setup("schnapper", pos)
	main.world.add_child(cell)
	main.ai_cells.append(cell)
	cell.motion.position = pos
	cell.position = pos
	var vorher: float = cell.health.hp
	main.resolve_combat()
	# Entweder nimmt Schaden oder wird ganz verschluckt (Ein-Biss-Regel).
	check(cell.health.hp < vorher or cell not in main.ai_cells, "Schnapper nimmt Schaden im Kampf oder wird verschluckt")
