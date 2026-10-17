extends "res://tests/base_test.gd"


func test_anzahl() -> void:
	check_eq(LightRayLayout.offsets(5, 1).size(), 5, "offsets gibt exakt so viele zurück wie angefragt")


func test_gleich_bei_gleichem_seed() -> void:
	var a := LightRayLayout.offsets(6, 7)
	var b := LightRayLayout.offsets(6, 7)
	var c := LightRayLayout.offsets(6, 8)
	for i in 6:
		check_eq(a[i], b[i], "gleicher Seed gibt gleiche Versätze")
	check(not a[0] == c[0], "ungleicher Seed gibt anderen Versatz")


func test_im_bereich() -> void:
	var offsets := LightRayLayout.offsets(LightRayLayout.COUNT, 3)
	for p in offsets:
		check(absf(p.x) <= LightRayLayout.SPREAD, "p.x im Bereich [-SPREAD, SPREAD]")
		check(absf(p.z) <= LightRayLayout.SPREAD, "p.z im Bereich [-SPREAD, SPREAD]")
		check_eq(p.y, 0.0, "p.y immer 0.0")


func test_neigung() -> void:
	var t_zero := LightRayLayout.tilt(0.0, 0)
	check_eq(t_zero, 0.25, "tilt(0.0, 0) ist 0.25")
	for t in range(31):
		for index in 4:
			var val := LightRayLayout.tilt(float(t), index)
			check(val >= 0.19 and val <= 0.31, "tilt(%d, %d) liegt zwischen 0.19 und 0.31" % [t, index])


func test_tiefe() -> void:
	var alpha_0 := LightRayLayout.alpha_for_depth(0.0)
	var alpha_45 := LightRayLayout.alpha_for_depth(45.0)
	var alpha_60 := LightRayLayout.alpha_for_depth(60.0)
	var alpha_10 := LightRayLayout.alpha_for_depth(10.0)
	var alpha_30 := LightRayLayout.alpha_for_depth(30.0)
	check_eq(alpha_0, 0.22, "alpha_for_depth(0.0) ist 0.22")
	check_eq(alpha_45, 0.0, "alpha_for_depth(45.0) ist 0.0")
	check_eq(alpha_60, 0.0, "alpha_for_depth(60.0) ist 0.0")
	check(alpha_10 > alpha_30, "alpha_for_depth(10.0) > alpha_for_depth(30.0)")
