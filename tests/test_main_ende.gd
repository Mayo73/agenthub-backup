extends "res://tests/base_test.gd"

var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()


func test_noch_nicht() -> void:
	main.finish_phase()
	check(not main.finished, "main.finished soll falsch sein")
	check(not main.end_screen.visible, "main.end_screen.visible soll falsch sein")


func test_ende() -> void:
	main.progress.eat(100)
	main.finish_phase()
	check(main.finished, "main.finished soll wahr sein")
	check(main.end_screen.visible, "main.end_screen.visible soll wahr sein")
	check(main.world.process_mode == Node.PROCESS_MODE_DISABLED, "main.world.process_mode soll DISABLED sein")


func test_knopf() -> void:
	main.progress.eat(100)
	main._process(0.016)
	check(main.hud.finish_button.visible, "main.hud.finish_button.visible soll wahr sein")


func test_knopf_loest_aus() -> void:
	main.progress.eat(100)
	main.hud.finish_button.pressed.emit()
	check(main.finished, "main.finished soll wahr sein nach Button-Klick")


func test_zurueck_ins_menue() -> void:
	main.progress.eat(100)
	main.finish_phase()
	main.end_screen.menu_button.pressed.emit()
	check(not main.end_screen.visible, "main.end_screen.visible soll falsch sein")
	check(main.in_menu, "main.in_menu soll wahr sein")
	check(not main.finished, "main.finished soll falsch sein")
