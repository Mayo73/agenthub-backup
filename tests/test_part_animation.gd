extends "res://tests/base_test.gd"


func test_punkte() -> void:
	var f := PartAnimation.flagellum(0.0)
	check_eq(f.size(), 8, "flagellum hat 8 Punkte")
	check(f[0].is_equal_approx(Vector2.ZERO), "Ansatz ist bei (0, 0)")
	check_eq(f[7].x, -0.9, "Ende liegt bei x = -0.9")


func test_schwingt() -> void:
	check_eq(PartAnimation.flagellum(0.0)[7].y, 0.12 * sin(-6.0), "y an Ende bei t=0 ist 0.12*sin(-6)")
	check_eq(PartAnimation.flagellum(0.1)[7].y, 0.12 * sin(1.0 - 6.0), "y an Ende bei t=0.1 ist 0.12*sin(1.0-6)")


func test_ansatz_ruhig() -> void:
	for t in [0.0, 0.3, 2.0]:
		check(PartAnimation.flagellum(t)[0].is_equal_approx(Vector2.ZERO), "Ansatz bleibt bei (0, 0) für t=%.1f" % t)


func test_hinten() -> void:
	var p := PartAnimation.place_points(PackedVector2Array([Vector2(-1, 0)]), {"id": "geissel", "pos": Vector2(-1, 0), "angle": 0.0}, 10.0)
	check(p[0].is_equal_approx(Vector2(-20, 0)), "Geißel bei pos=(-1,0) wird nach hinten gelegt")


func test_seitlich() -> void:
	var p := PartAnimation.place_points(PackedVector2Array([Vector2.ZERO, Vector2(-1, 0)]), {"id": "geissel", "pos": Vector2(0, 1), "angle": 0.0}, 10.0)
	check(p[0].is_equal_approx(Vector2(0, 10)), "Startpunkt bei (0,0) wird auf pos*radius gelegt")
	check(p[1].is_equal_approx(Vector2(0, 20)), "Endpunkt bei (-1,0) wird um 90° gedreht nach außen")
