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
