extends "res://tests/base_test.gd"


func test_pupille() -> void:
	check(EyeLook.pupil_offset(Vector2(10, 0), 1.0).is_equal_approx(Vector2(0.45, 0)),
		"pupil_offset(Vector2(10, 0), 1.0) sollte Vector2(0.45, 0) sein")
	check(EyeLook.pupil_offset(Vector2(0, -3), 2.0).is_equal_approx(Vector2(0, -0.9)),
		"pupil_offset(Vector2(0, -3), 2.0) sollte Vector2(0, -0.9) sein")
	check(EyeLook.pupil_offset(Vector2.ZERO, 1.0) == Vector2.ZERO,
		"pupil_offset(Vector2.ZERO, 1.0) sollte Vector2.ZERO sein")


func test_blinzeln() -> void:
	check(EyeLook.openness(0.05) == 0.1, "openness(0.05) sollte 0.1 sein")
	check(EyeLook.openness(1.0) == 1.0, "openness(1.0) sollte 1.0 sein")
	check(EyeLook.openness(4.05) == 0.1, "openness(4.05) sollte 0.1 sein")
	check(EyeLook.openness(0.05, 1.0) == 1.0, "openness(0.05, 1.0) sollte 1.0 sein")


func test_lage() -> void:
	check(EyeLook.eye_center({"id": "knopfauge", "pos": Vector2(0.5, 0.3)}, 10.0).is_equal_approx(Vector2(5, 3)),
		"eye_center für Knopfaug bei Radius 10 sollte (5, 3) sein")
	check(EyeLook.eye_center({"id": "stielauge", "pos": Vector2(1, 0)}, 10.0).is_equal_approx(Vector2(13.5, 0)),
		"eye_center für Stielauge bei Radius 10 sollte (13.5, 0) sein")


func test_groesse() -> void:
	check(is_equal_approx(EyeLook.eye_radius("stielauge", 10.0), 1.8), "eye_radius('stielauge', 10.0) sollte 1.8 sein")
	check(is_equal_approx(EyeLook.eye_radius("knopfauge", 10.0), 1.3), "eye_radius('knopfauge', 10.0) sollte 1.3 sein")
