extends "res://tests/base_test.gd"


func test_ohne_streuung() -> void:
	var result: Vector3 = Spread.direction(Vector3(0, 0, -2), 0.0, 1)
	check_eq(result, Vector3(0, 0, -1), "Richtung bei 0 Grad Streuung")


func test_wiederholbar() -> void:
	var r1: Vector3 = Spread.direction(Vector3(0, 0, -1), 5.0, 7)
	var r2: Vector3 = Spread.direction(Vector3(0, 0, -1), 5.0, 7)
	check(r1.is_equal_approx(r2), "gleiche Seeds ergeben gleiche Richtungen")

	var r3: Vector3 = Spread.direction(Vector3(0, 0, -1), 5.0, 1)
	check(not r1.is_equal_approx(r3), "verschiedene Seeds ergeben verschiedene Richtungen")


func test_kegel() -> void:
	for seed in range(1, 51):
		var d: Vector3 = Spread.direction(Vector3(0, 0, -1), 5.0, seed)
		var angle: float = rad_to_deg(d.angle_to(Vector3(0, 0, -1)))
		check(angle <= 5.001, "Seed %d: Winkel %f nicht größer als 5.001 Grad" % [seed, angle])
		check(absf(d.length() - 1.0) < 0.001, "Seed %d: Länge %f nicht etwa 1" % [seed, d.length()])


func test_senkrecht() -> void:
	var d: Vector3 = Spread.direction(Vector3.UP, 3.0, 4)
	check(absf(d.length() - 1.0) < 0.001, "Länge etwa 1")
	var angle: float = rad_to_deg(d.angle_to(Vector3.UP))
	check(angle <= 3.001, "Winkel höchstens 3.001 Grad zu Vector3.UP")
