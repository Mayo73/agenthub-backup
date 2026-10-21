extends "res://tests/base_test.gd"


func test_ruhendes_ziel() -> void:
	var t: float = LeadSolver.intercept_time(Vector3.ZERO, Vector3(10, 0, 0), Vector3.ZERO, 5.0)
	check(abs(t - 2.0) < 0.001, "ruhendes Ziel bei 10 Einheiten Entfernung mit speed=5")


func test_bewegtes_ziel() -> void:
	var t: float = LeadSolver.intercept_time(Vector3.ZERO, Vector3(10, 0, 0), Vector3(0, 0, 3), 5.0)
	check(abs(t - 2.5) < 0.001, "Treffzeit für bewegtes Ziel")

	var point: Vector3 = LeadSolver.intercept_point(Vector3.ZERO, Vector3(10, 0, 0), Vector3(0, 0, 3), 5.0)
	var expected_point: Vector3 = Vector3(10, 0, 7.5)
	check(point.distance_to(expected_point) < 0.001, "Treffpunkt liegt bei (10, 0, 7.5)")


func test_zu_langsam() -> void:
	var t: float = LeadSolver.intercept_time(Vector3.ZERO, Vector3(10, 0, 0), Vector3(10, 0, 0), 5.0)
	check_eq(t, -1.0, "kein Treffpunkt bei zu langschem Geschoss")

	var point: Vector3 = LeadSolver.intercept_point(Vector3.ZERO, Vector3(10, 0, 0), Vector3(10, 0, 0), 5.0)
	check_eq(point, Vector3(10, 0, 0), "intercept_point gibt Ziel zurück wenn zu langsam")


func test_richtung() -> void:
	var dir: Vector3 = LeadSolver.aim_direction(Vector3.ZERO, Vector3(10, 0, 0), Vector3(0, 0, 3), 5.0)
	check(abs(dir.length() - 1.0) < 0.001, "aim_direction ergibt normierte Richtung")
	check(dir.z > 0.0, "Richtung hat positive z-Komponente")
