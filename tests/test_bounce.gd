extends "res://tests/base_test.gd"

func test_punkte() -> void:
	var result: Dictionary = Bounce.simulate_2d(Vector2(0, -5), Vector2.ZERO, 0.0, 0.5, 2.0)
	var points_size: int = result["points"].size()
	check_eq(points_size, 241, "punkte: 2 s * 120 Hz + 1 = 241")

func test_bleibt_ueber_boden() -> void:
	var result: Dictionary = Bounce.simulate_2d(Vector2(0, -5), Vector2(3, 0), 0.0, 0.7, 4.0)
	var points: PackedVector2Array = result["points"] as PackedVector2Array
	var bounces: int = result["bounces"]

	for pt in points:
		check(pt.y <= 0.0001, "alle Punkte y <= 0.0001")

	check(bounces >= 2, "mindestens 2 Bounces erwartet")

func test_energieverlust() -> void:
	var result: Dictionary = Bounce.simulate_2d(Vector2(0, -5), Vector2.ZERO, 0.0, 0.5, 6.0)
	var points: PackedVector2Array = result["points"] as PackedVector2Array
	var peak_heights: Array[float] = Bounce.peak_heights_2d(points, 0.0)

	check(peak_heights.size() >= 2, "mindestens 2 Hochpunkte erwartet")

	if peak_heights.size() >= 2:
		var first_peak: float = peak_heights[0]
		var second_peak: float = peak_heights[1]

		check(second_peak < first_peak, "zweiter Hochpunkt kleiner als erster")

		var ratio: float = second_peak / first_peak
		check(ratio > 0.2 and ratio < 0.3, "Verhältnis zweiter/erster zwischen 0.2 und 0.3 (ideal %.1f)" % [ratio])

func test_kein_rueckprall() -> void:
	var result: Dictionary = Bounce.simulate_2d(Vector2(0, -2), Vector2.ZERO, 0.0, 0.0, 2.0)
	var points: PackedVector2Array = result["points"] as PackedVector2Array
	var final_velocity: Vector2 = result["velocity"]

	var last_point: Vector2 = points[points.size() - 1]
	check(absf(last_point.y) < 0.001, "letzter Punkt y ca. 0 (Toleranz 0.001)")
	check(final_velocity.y == 0.0, "velocity.y am Ende 0")

func test_3d() -> void:
	var result: Dictionary = Bounce.simulate_3d(Vector3(0, 3, 0), Vector3(1, 0, 2), 0.0, 0.6, 3.0)
	var points: PackedVector3Array = result["points"] as PackedVector3Array
	var bounces: int = result["bounces"]

	for pt in points:
		check(pt.y >= -0.0001, "alle Punkte y >= -0.0001")

	check(bounces >= 1, "mindestens 1 Bounce erwartet")

	var last_point: Vector3 = points[points.size() - 1]
	check(absf(last_point.x - 3.0) < 0.05, "letzter Punkt x ca. 3 (Toleranz 0.05)")
	check(absf(last_point.z - 6.0) < 0.05, "letzter Punkt z ca. 6 (Toleranz 0.05)")
