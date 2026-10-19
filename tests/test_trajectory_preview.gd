extends "res://tests/base_test.gd"

func test_ohne_wand() -> void:
	var result: Dictionary = TrajectoryPreview.preview_2d(Vector2.ZERO, Vector2(10, 0), [], 1.0)
	var points: PackedVector2Array = result["points"] as PackedVector2Array
	var hit: Dictionary = result["hit"] as Dictionary

	check_eq(points.size(), 31, "31 Punkte bei 1s Dauer und 30 Hz")
	check(hit.is_empty(), "hit ist leer ohne Wand")

func test_wand() -> void:
	var walls: Array[Rect2] = [Rect2(5, -10, 1, 20)]
	var result: Dictionary = TrajectoryPreview.preview_2d(Vector2.ZERO, Vector2(10, 0), walls, 2.0)
	var points: PackedVector2Array = result["points"] as PackedVector2Array
	var hit: Dictionary = result["hit"] as Dictionary

	check(hit.is_empty() == false, "hit ist nicht leer bei Wand")
	check_eq(hit.get("index", -1), 0, "hit.index ist 0")

	var last_point: Vector2 = points[points.size() - 1]
	check(abs(last_point.x - 5.0) < 0.01, "letzter Punkt hat x ungefähr 5.0 (Toleranz 0.01)")

	check(points.size() < 61, "weniger als 61 Punkte")

func test_schwerkraft() -> void:
	var walls: Array[Rect2] = []
	var result: Dictionary = TrajectoryPreview.preview_2d(Vector2.ZERO, Vector2(0, 0), walls, 1.0)
	var points: PackedVector2Array = result["points"] as PackedVector2Array

	var last_point: Vector2 = points[points.size() - 1]
	check(abs(last_point.y - 4.905) < 0.01, "letzter Punkt y ungefähr 4.905 bei (0,0) Geschwindigkeit und 1s")

func test_array() -> void:
	var packed: PackedVector2Array = PackedVector2Array([Vector2(1, 2)])
	var result: Array = TrajectoryPreview.to_array(packed)

	check(result.size() == 1, "result hat Größe 1")
	check_eq(result[0][0], 1.0, "result[0][0] ist 1.0")
	check_eq(result[0][1], 2.0, "result[0][1] ist 2.0")
