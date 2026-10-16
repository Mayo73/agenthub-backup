extends "res://tests/base_test.gd"

var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()


func test_kauen_beim_fressen() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	main.food.items.clear()
	main.food.add_item(Diet.PFLANZE, main.player.mouth_point())
	main.feed_player()
	check(main.player.chew_left > 0.0, "Zelle sollte kauen nach dem Fressen")


func test_kauen_beim_biss() -> void:
	main.start_new(Diet.FLEISCHFRESSER)
	var cell := AiCell.new()
	cell.setup("schnapper", Vector2(30.0, 0.0))
	cell.motion.heading = 0.0
	main.world.add_child(cell)
	main.ai_cells.append(cell)
	# Warte einen Schritt, damit sich die Zellen näher kommen
	for _i in range(5):
		main.resolve_combat()
	check(main.player.chew_left > 0.0, "Zelle sollte kauen nach dem Beißen")


func test_ruhig() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	check_eq(main.player.chew_left, 0.0, "chew_left soll 0 sein am Anfang")
	check_eq(main.player.pulse_left, 0.0, "pulse_left soll 0 sein am Anfang")
