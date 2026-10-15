extends "res://tests/base_test.gd"

var main: Node2D

func setup() -> void:
	main = preload("res://scenes/main.tscn").instantiate()
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


func test_geisterauto_ist_verdrahtet() -> void:
	check(main.get_node("World/Ghost") != null, "Ghost-Node existiert")
	check(main.ghost_best == null, "ghost_best ist zu Beginn null")

	main.ghost_recording.record(0.0, Vector2.ZERO, 0.0)
	main._on_lap_completed(1, 30.0, true)
	check(main.ghost_best != null, "ghost_best ist nach schneller Runde gesetzt")
	check(main.ghost_recording.is_empty(), "ghost_recording ist leer nach _on_lap_completed")

	var first: GhostLap = main.ghost_best
	main.restart()
	check(main.ghost_best == first, "ghost_best bleibt nach restart() erhalten")


func test_pausemenue_ist_verdrahtet() -> void:
	check(main.get_node("PauseMenu") != null, "PauseMenu-Node existiert in main")

	check(main.pause_menu.restart_requested.is_connected(main.restart),
		"pause_menu.restart_requested ist mit main.restart verbunden")

	main.race.phase = RaceState.Phase.FINISHED
	main.pause_menu._on_restart()

	check(main.race.phase == RaceState.Phase.COUNTDOWN,
		"main.race.phase ist COUNTDOWN nach _on_restart()")
	check(not main.get_tree().paused, "get_tree().paused ist falsch nach _on_restart()")


func test_ergebnis_knoepfe() -> void:
	check(not main.hud.result_buttons.visible, "result_buttons.visible ist false zu Beginn")

	main.race.phase = RaceState.Phase.FINISHED
	main.hud.show_race(main.race, 42)
	check(main.hud.result_buttons.visible, "result_buttons.visible ist true nach FINISHED")

	check(main.hud.again_pressed.is_connected(main.restart),
		"again_pressed ist mit restart verbunden")
	check(main.hud.menu_pressed.is_connected(main.go_to_menu),
		"menu_pressed ist mit go_to_menu verbunden")

	main.hud.again_button.pressed.emit()
	check(main.race.phase == RaceState.Phase.COUNTDOWN,
		"phase ist COUNTDOWN nach Again-Knopf")

	check(ResourceLoader.exists(main.MENU_SCENE), "MENU_SCENE existiert")


func test_gewaehlte_strecke_wird_geladen() -> void:
	check(GameSettings.track_id == TrackCatalog.DEFAULT_ID,
		"GameSettings.track_id ist TrackCatalog.DEFAULT_ID")
	check(main.track.track_id == GameSettings.track_id,
		"main.track.track_id ist GameSettings.track_id")
	check(main.car.track == main.track.path,
		"main.car.track == main.track.path")


func test_ergebnis_wird_gespeichert() -> void:
	var path := "user://test_main_bestenliste.json"
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

	main.highscore_path = path
	main.race.race_time = 90.0
	main.record_result()
	check(main.last_record["new_time"], "last_record['new_time'] ist wahr")

	var table := HighscoreTable.load_from(path)
	check_eq(table.best_time(main.track.track_id), 90.0, "best_time(track_id) ist 90.0")

	main.restart()
	check(main.last_record.is_empty(), "last_record.is_empty() ist wahr nach restart()")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func test_gewaehlte_auto_wird_geladen() -> void:
	check(main.car.car_id == GameSettings.car_id,
		"main.car.car_id ist GameSettings.car_id")

	main.car.apply_car("grip")
	check(main.car.car_id == "grip",
		"main.car.car_id ist 'grip' nach apply_car('grip')")
	check(main.car.physics.grip == 34.0,
		"main.car.physics.grip ist 34.0")
	var body_color := (main.car.get_node("Body") as Polygon2D).color
	check(body_color == CarCatalog.color_of("grip"),
		"main.car.Body.color ist CarCatalog.color_of('grip')")

	main.car.apply_car("allround")
	check(main.car.physics.grip == 30.0,
		"main.car.physics.grip ist 30.0 nach apply_car('allround') (alte Werte bleiben nicht hängen)")

	main.car.apply_car("gibtsnicht")
	check(main.car.car_id == "allround",
		"main.car.car_id bleibt 'allround' bei unbekannter ID")


func test_ki_gegner() -> void:
	check(main.ai_cars.size() == 3, "ai_cars.size() ist 3")
	check(main.get_node("World/Ai1") != null, "World/Ai1 existiert")

	for ai in main.ai_cars:
		check(ai.track == main.track.path, "ai.track == main.track.path")
		check(not ai.driving_enabled, "ai.driving_enabled ist falsch zu Beginn")
		check(ai.physics.position.distance_to(main.car.physics.position) > 50.0,
			"Abstand zwischen AI und Spieler > 50.0")

	check(main.ai_cars[0].physics.position.distance_to(main.ai_cars[1].physics.position) > 50.0,
		"Abstand zwischen Ai1 und Ai2 > 50.0")

	main.ai_cars[0].place_at(Vector2(5000, 5000), 0.0)
	main.restart()
	check(main.ai_cars[0].physics.position.distance_to(main.track.path.start_position()) < 200.0,
		"AI ist nach restart() wieder am Start")


func test_zusammenstoesse() -> void:
	main.car.physics.position = Vector2(0, 0)
	main.ai_cars[0].physics.position = Vector2(10, 0)
	main.ai_cars[1].physics.position = Vector2(5000, 0)
	main.ai_cars[2].physics.position = Vector2(-5000, 0)
	main.resolve_collisions()
	check(main.car.physics.position.distance_to(main.ai_cars[0].physics.position) >= 2.0 * main.CAR_RADIUS - 0.01,
		"Abstand nach Kollisionsauflösung mindestens 2*CAR_RADIUS - 0.01")
