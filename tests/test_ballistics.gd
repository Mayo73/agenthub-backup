extends "res://tests/base_test.gd"

func test_position_2d() -> void:
	var pos: Vector2 = Ballistics.position_2d(Vector2.ZERO, Vector2(10, -10), 1.0)
	check_eq(pos.x, 10.0, "x ist 10")
	check(abs(pos.y - (-5.095)) < 0.0001, "y ist -5.095")

func test_position_3d() -> void:
	var pos: Vector3 = Ballistics.position_3d(Vector3.ZERO, Vector3(0, 10, 5), 1.0)
	check(abs(pos.y - 5.095) < 0.0001, "y ist 5.095")
	check_eq(pos.z, 5.0, "z ist 5")

func test_simulation_punkte() -> void:
	var points: PackedVector2Array = Ballistics.simulate_2d(Vector2.ZERO, Vector2(20, -15), 2.0)
	check_eq(points.size(), 241, "Simulation mit 2 s und 120 Hz hat 241 Punkte")

func test_abweichung_2d() -> void:
	var points: PackedVector2Array = Ballistics.simulate_2d(Vector2.ZERO, Vector2(20, -15), 2.0)
	var err: float = Ballistics.max_error_2d(points, Vector2.ZERO, Vector2(20, -15))
	check(err < 0.15, "max_error_2d < 0.15")

func test_abweichung_3d() -> void:
	var points: PackedVector3Array = Ballistics.simulate_3d(Vector3(0, 1, 0), Vector3(5, 12, -3), 2.0)
	var err: float = Ballistics.max_error_3d(points, Vector3(0, 1, 0), Vector3(5, 12, -3))
	check(err < 0.15, "max_error_3d < 0.15")

func test_ende_wie_analytisch() -> void:
	var duration: float = 2.0
	var points: PackedVector3Array = Ballistics.simulate_3d(Vector3(0, 1, 0), Vector3(5, 12, -3), duration)

	var last_point: Vector3 = points[points.size() - 1]
	var analytic_pos: Vector3 = Ballistics.position_3d(Vector3(0, 1, 0), Vector3(5, 12, -3), duration)

	var err: float = (last_point - analytic_pos).length()
	check(err < 0.15, "letzter Punkt liegt weniger als 0.15 von analytischer Position entfernt")

func test_landezeit() -> void:
	## time_to_height_2d(0.0, -10.0, 0.0) sollte ≈ 2.0387 ergeben (ca. 20 / 9.81)
	var t1: float = Ballistics.time_to_height_2d(0.0, -10.0, 0.0)
	check(abs(t1 - 2.0387) < 0.001, "time_to_height_2d(0, -10, 0) ≈ 2.0387")

	## time_to_height_2d(0.0, -10.0, -100.0) sollte -1.0 ergeben (keine Lösung mit t >= 0)
	var t2: float = Ballistics.time_to_height_2d(0.0, -10.0, -100.0)
	check_eq(t2, -1.0, "time_to_height_2d ohne positive Lösung liefert -1")
