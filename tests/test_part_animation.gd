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


func test_wimpern_anzahl() -> void:
	var c := PartAnimation.cilia(0.0)
	check_eq(c.size(), 5, "es gibt 5 Wimpern")
	check_eq(c[0].size(), 2, "jede Wimper hat 2 Punkte (Ansatz und Spitze)")


func test_wimpern_ansatz() -> void:
	var c := PartAnimation.cilia(0.7)
	check(c[0][0].is_equal_approx(Vector2(0, -0.25)), "erste Wimper startet bei y = -0.25")
	check(c[4][0].is_equal_approx(Vector2(0, 0.25)), "letzte Wimper startet bei y = 0.25")


func test_wimpern_laenge() -> void:
	for t in [0.0, 0.4, 1.3]:
		var c := PartAnimation.cilia(t)
		for w in c:
			var len := w[0].distance_to(w[1])
			check(len >= 0.299 && len <= 0.301, "Wimpernlänge bei t=%.1f ist ~0.3, gefunden %.4f" % [t, len])


func test_wimpern_schlagen() -> void:
	var tip_t0 := PartAnimation.cilia(0.0)[2][1]
	var tip_t01 := PartAnimation.cilia(0.1)[2][1]
	check(!tip_t0.is_equal_approx(tip_t01), "Wimper schlägt hin und her, Spitze ändert sich")


func test_duese() -> void:
	check_eq(PartAnimation.jet_scale(0.0), 1.0, "jet_scale bei t=0 ist 1.0")
	check_eq(PartAnimation.jet_scale(PI / 16.0), 1.15, "jet_scale bei PI/16 ist 1.15")
