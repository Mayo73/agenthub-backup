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
