extends "res://tests/base_test.gd"

const P := "user://test_abnahme_antrieb.json"
var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	main.save_path = P
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()
	var dir := DirAccess.open("user://")
	if dir and dir.file_exists("test_abnahme_antrieb.json"):
		dir.remove("test_abnahme_antrieb.json")


func test_tempo() -> void:
	main.start_scene("tempo")
	var expected_speed := CellStats.max_speed(CellBuild.starter(Diet.PFLANZENFRESSER), 1)
	check(main.player.motion.max_speed > expected_speed, "Geißeln machen schneller: max_speed=%.2f, erwartet=%.2f" % [main.player.motion.max_speed, expected_speed])
	check(main.player.build.count("geissel") == 2, "tempo-Szene hat 2 Geißeln, gefunden=%d" % main.player.build.count("geissel"))


func test_tempo_gemessen() -> void:
	main.start_scene("tempo")
	for _i in range(120):
		main.player.drive(1.0 / 60.0, Vector2(1, 0))
	var schnell: float = main.player.motion.position.x

	var p := PlayerCell.new()
	p.set_stage(1)
	p.set_build(CellBuild.starter(Diet.PFLANZENFRESSER))
	for _i in range(120):
		p.drive(1.0 / 60.0, Vector2(1, 0))

	check(schnell > p.motion.position.x, "Zelle mit Geißeln schwimmt weiter: schnell=%.2f, Vergleich=%.2f" % [schnell, p.motion.position.x])
	p.free()


func test_wendigkeit() -> void:
	main.start_scene("wendigkeit")
	var expected_turn := CellStats.turn_rate(CellBuild.starter(Diet.PFLANZENFRESSER))
	check(main.player.motion.turn_rate > expected_turn, "Wimpern machen wendiger: turn_rate=%.2f, erwartet=%.2f" % [main.player.motion.turn_rate, expected_turn])
	check(main.player.build.count("wimpern") == 2, "wendigkeit-Szene hat 2 Wimpern, gefunden=%d" % main.player.build.count("wimpern"))


func test_wendigkeit_gemessen() -> void:
	main.start_scene("wendigkeit")
	for _i in range(10):
		main.player.drive(1.0 / 60.0, Vector2(0, 1))
	var w: float = absf(main.player.motion.heading)

	var p := PlayerCell.new()
	p.set_stage(1)
	p.set_build(CellBuild.starter(Diet.PFLANZENFRESSER))
	for _i in range(10):
		p.drive(1.0 / 60.0, Vector2(0, 1))

	check(w > absf(p.motion.heading), "Zelle mit Wimpern dreht schärfer: w=%.4f, Vergleich=%.4f" % [w, absf(p.motion.heading)])
	p.free()
