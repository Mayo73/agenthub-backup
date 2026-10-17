extends "res://tests/base_test.gd"

var main: Node2D

func setup() -> void:
	main = preload("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()
	main = null


func test_vorhanden() -> void:
	check(main.world.get_node("PlayerMarker") is PlayerMarker, "PlayerMarker existiert in World")
	check(main.player_marker.target == main.car, "player_marker.target ist car")


func test_unter_dem_auto() -> void:
	check(main.player_marker.get_index() < main.car.get_index(), "PlayerMarker ist unter Car in World")


func test_folgt() -> void:
	main.car.position = Vector2(300, 120)
	main.player_marker.follow()
	check_eq(main.player_marker.position, Vector2(300, 120), "position folgt car.position")
	check_eq(main.player_marker.rotation, 0.0, "rotation ist 0.0")


func test_ohne_ziel() -> void:
	var m := PlayerMarker.new()
	m.follow()
	check_eq(m.position, Vector2.ZERO, "position ist Vector2.ZERO ohne Ziel")
	m.free()
