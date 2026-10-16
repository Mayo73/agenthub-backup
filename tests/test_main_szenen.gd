extends "res://tests/base_test.gd"

var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()


func test_jagd() -> void:
	main.start_scene("jagd")
	check_eq(main.ai_cells.size(), 1, "es gibt genau eine KI-Zelle")
	check(main.ai_cells[0].species_id == "schnapper", "die KI-Zelle ist ein Schnapper")
	check(main.autosave == false, "autosave ist falsch in Vorführszene")
	check(main.in_menu == false, "nicht im Menü während Vorführszene")
	check(main.hud.message_label.text == "Ein Schnapper jagt die kleine Spielerzelle.", "Hinweistext korrekt")


func test_kein_nachschub() -> void:
	main.start_scene("jagd")
	var size: int = main.ai_cells.size()
	main._physics_process(0.016)
	check_eq(main.ai_cells.size(), size, "keine neuen KI-Zellen nach einem Tick")


func test_nahrung() -> void:
	main.start_scene("nahrung")
	check_eq(main.food.items.size(), 1, "es gibt genau ein Nahrungselement")
	check(main.player.diet == Diet.PFLANZENFRESSER, "Ernährung ist Pflanzenfresser")


func test_tempo() -> void:
	main.start_scene("tempo")
	var parts_count: int = main.player.build.parts.size()
	check(parts_count == 4, "vier Teile nach Tempo-Szene")
	var starter_max_speed := CellStats.max_speed(CellBuild.starter(Diet.PFLANZENFRESSER), 1)
	check(main.player.motion.max_speed > starter_max_speed, "max_speed höher als Starter")


func test_groesse() -> void:
	main.start_scene("flucht")
	check_eq(main.progress.stage, 3, "Stufe 3 in Flucht-Szene")
	check_eq(main.player.radius, 40.0, "Radius ist 40.0 in Stufe 3")
