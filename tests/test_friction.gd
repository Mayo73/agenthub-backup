extends "res://tests/base_test.gd"


func test_kombinieren() -> void:
	var c1: float = Friction.combine(0.5, 0.5)
	check_eq(c1, 0.5, "combine(0.5, 0.5) ist 0.5")

	var c2: float = Friction.combine(1.0, 0.0)
	check_eq(c2, 0.0, "combine(1.0, 0.0) ist 0.0")


func test_bremsen() -> void:
	## slide(Vector2(2, 0), Vector2(0, -1), 0.5, 9.81, 0.1)
	var v: Vector2 = Friction.slide(Vector2(2, 0), Vector2(0, -1), 0.5, 9.81, 0.1)
	check(absf(v.x - 1.5095) < 0.0001, "slide: x ist ungefähr 1.5095")
	check_eq(v.y, 0.0, "slide: y ist 0.0")


func test_stehen() -> void:
	var v: Vector2 = Friction.slide(Vector2(0.1, 0), Vector2(0, -1), 0.5, 9.81, 0.1)
	check_eq(v, Vector2.ZERO, "slide bei geringer Geschwindigkeit führt zu 0")


func test_normal_bleibt() -> void:
	var v: Vector2 = Friction.slide(Vector2(2, 3), Vector2(0, -1), 0.5, 9.81, 0.1)
	check_eq(v.y, 3.0, "slide: senkrechter Anteil bleibt unverändert (y=3.0)")


func test_3d() -> void:
	var v: Vector3 = Friction.slide_3d(Vector3(0, 0, -2), Vector3.UP, 0.5, 9.81, 0.1)
	check(absf(v.z - (-1.5095)) < 0.0001, "slide_3d: z ist ungefähr -1.5095")


func test_bremsweg() -> void:
	var d: float = Friction.stop_distance(10.0, 0.5, 9.81)
	check(absf(d - 10.194) < 0.01, "stop_distance(10, 0.5, 9.81) ist ungefähr 10.194")

	var d_inf: float = Friction.stop_distance(10.0, 0.0, 9.81)
	check(is_inf(d_inf), "stop_distance mit mu=0 liefert unendlich")
