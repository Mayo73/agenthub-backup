extends "res://tests/base_test.gd"


func test_zwei_bahnen() -> void:
	var list: Array[float] = AimSolver.angles(20.0, 0.0, 20.0)
	check_eq(list.size(), 2, "zwei Bahnen")
	if list.size() == 2:
		check(list[0] < list[1], "flache Bahn zuerst")
		check(absf(list[0] + list[1] - PI / 2.0) < 0.001, "Winkel ergänzen sich zu PI/2")


func test_unerreichbar() -> void:
	check(AimSolver.angles(100.0, 0.0, 10.0).is_empty(), "zu weit")
	check_eq(AimSolver.direction_3d(Vector3.ZERO, Vector3(100, 0, 0), 10.0), Vector3.ZERO, "kein Vektor")


func test_trifft() -> void:
	var target := Vector3(12, 2, -9)
	var v := AimSolver.direction_3d(Vector3.ZERO, target, 25.0)
	check(absf(v.length() - 25.0) < 0.001, "Länge 25")
	var t := AimSolver.flight_time(15.0, asin(v.y / 25.0), 25.0)
	var hit := Ballistics.position_3d(Vector3.ZERO, v, t)
	check(hit.distance_to(target) < 0.01, "trifft das Ziel, Abstand %f" % hit.distance_to(target))


func test_steil() -> void:
	var target := Vector3(12, 2, -9)
	var low := AimSolver.direction_3d(Vector3.ZERO, target, 25.0)
	var high := AimSolver.direction_3d(Vector3.ZERO, target, 25.0, true)
	check(high.y > low.y, "steile Bahn steigt stärker")
