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


func test_rennablauf_ist_verdrahtet() -> void:
	check(main.race is RaceState, "main.race ist ein RaceState")
	check(not main.car.input_enabled, "main.car.input_enabled ist falsch (Countdown läuft)")
	check(main.lap_timer.lap_completed.is_connected(main._on_lap_completed),
	      "lap_completed ist mit _on_lap_completed verbunden")

	main.race.phase = RaceState.Phase.FINISHED
	main.scorer.total = 500
	main.restart()

	check(main.race.phase == RaceState.Phase.COUNTDOWN,
	      "main.race.phase ist COUNTDOWN nach restart()")
	check(main.scorer.total == 0, "main.scorer.total ist 0 nach restart()")
