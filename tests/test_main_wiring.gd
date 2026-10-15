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


func test_rennanzeige() -> void:
	check(main.hud.has_method("show_race"), "HUD hat show_race")

	main.hud.show_race(main.race, 0)
	check_eq(main.hud.countdown_label.text, "3", "Countdown beginnt mit '3'")
	check(not main.hud.result_label.visible, "Result-Label ist unsichtbar während Countdown")

	main.race.phase = RaceState.Phase.FINISHED
	main.hud.show_race(main.race, 42)
	check(main.hud.result_label.visible, "Result-Label ist sichtbar nach FINISHED")
	check(main.hud.result_label.text.contains("Punkte 42"), "Ergebnis enthält Punktezahl 42")

	main.lap_timer = LapTimer.new(100.0)
	main.hud.show_laps(main.lap_timer)
	check_eq(main.hud.lap_label.text, "Runde 1/3", "Rundenanzeige mit Gesamtrundenzahl")


func test_neustart_loescht_spuren() -> void:
	var marks: Node2D = main.get_node("World/SkidMarks")
	marks.left.update(Vector2.ZERO, true)
	marks.left.update(Vector2(10, 0), true)
	main.restart()
	check_eq(marks.left.point_count(), 0, "Spuren nach restart() gelöscht")
