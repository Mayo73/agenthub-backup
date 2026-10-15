extends "res://tests/base_test.gd"

var main: Node

func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()
	main = null


func test_wertung_und_rundenzeit_sind_verdrahtet() -> void:
	check(main.scorer is DriftScorer, "main.scorer ist ein DriftScorer")
	check(main.lap_timer is LapTimer, "main.lap_timer ist ein LapTimer")
	check_eq(main.lap_timer.track_length, main.track.path.length, "Rundenlänge = Streckenlänge")
	check(main.hud.has_method("show_score"), "HUD hat show_score")
	check(main.hud.has_method("show_laps"), "HUD hat show_laps")
