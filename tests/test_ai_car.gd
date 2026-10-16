extends "res://tests/base_test.gd"

var ai: Node2D


func setup() -> void:
	ai = preload("res://scripts/ai_car.gd").new()
	ai.track = TrackPath.new(TrackPath.smooth_closed(TrackCatalog.points_of("hafen"), 10), 280.0)


func teardown() -> void:
	ai.free()


func test_platzieren() -> void:
	ai.place_at(Vector2(10, 20), 0.5)
	check_eq(ai.position, Vector2(10, 20), "position")
	check_eq(ai.physics.position, Vector2(10, 20), "physics.position")
	check_eq(ai.rotation, 0.5, "rotation")


func test_steht_ohne_freigabe() -> void:
	ai.place_at(ai.track.start_position(), ai.track.start_heading())
	for i in range(30):
		ai._physics_process(1.0 / 60.0)
	check(ai.physics.speed() < 1.0, "speed sollte < 1 sein")


func test_faehrt_mit_freigabe() -> void:
	ai.place_at(ai.track.start_position(), ai.track.start_heading())
	ai.driving_enabled = true
	for i in range(60):
		ai._physics_process(1.0 / 60.0)
	check(ai.physics.speed() > 50.0, "speed sollte > 50 sein")
	check(ai.track.is_on_track(ai.physics.position), "sollte auf der Strecke bleiben")


func test_zaehlt_strecke() -> void:
	ai.place_at(ai.track.start_position(), ai.track.start_heading())
	check(ai.lap_timer != null, "lap_timer sollte nicht null sein")
	check_eq(ai.race_distance(), 0.0, "race_distance sollte 0.0 sein nach place_at")

	ai.driving_enabled = true
	for i in range(120):
		ai._physics_process(1.0 / 60.0)
	check(ai.race_distance() > 100.0, "race_distance sollte > 100.0 sein nach 120 Schritten")

	ai.place_at(ai.track.start_position(), ai.track.start_heading())
	check_eq(ai.race_distance(), 0.0, "race_distance sollte wieder 0.0 sein nach place_at")


func test_auto_waehlen() -> void:
	check(ai.texture == null, "texture sollte am Anfang null sein")
	ai.set_car("drifter")
	check_eq(ai.car_id, "drifter", "car_id sollte drifter sein")
	check(ai.texture.resource_path == "res://assets/cars/car_drifter.png", "texture path sollte stimmen")
	ai.set_car("gibtsnicht")
	check_eq(ai.car_id, "drifter", "car_id bleibt drifter bei unbekannter ID")


func test_motorgeraeusch() -> void:
	(Engine.get_main_loop() as SceneTree).root.add_child(ai)
	check(ai.engine_player != null, "engine_player sollte nicht null sein")
	check(ai.get_node("Engine") is AudioStreamPlayer2D, "Node 'Engine' sollte AudioStreamPlayer2D sein")
	check(ai.engine_player.stream is AudioStreamWAV, "stream sollte AudioStreamWAV sein")
	ai.place_at(ai.track.start_position(), ai.track.start_heading())
	ai.physics.velocity = Vector2.from_angle(ai.physics.heading) * ai.physics.max_speed
	ai._physics_process(0.0)
	check(ai.engine_player.pitch_scale > 1.9, "pitch_scale sollte > 1.9 sein")
