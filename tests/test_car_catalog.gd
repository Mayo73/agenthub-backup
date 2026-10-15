extends "res://tests/base_test.gd"

func test_drei_autos() -> void:
	var ids := CarCatalog.ids()
	check_eq(ids.size(), 3, "ids() hat Größe 3")
	check(ids.has("allround"), "ids() enthält 'allround'")
	check(ids.has("grip"), "ids() enthält 'grip'")
	check(ids.has("drifter"), "ids() enthält 'drifter'")
	check(CarCatalog.has_car(CarCatalog.DEFAULT_ID), "has_car(DEFAULT_ID) ist wahr")


func test_namen_und_farben() -> void:
	check_eq(CarCatalog.name_of("grip"), "Grip-Coupé", "name_of('grip') ist 'Grip-Coupé'")
	check_eq(CarCatalog.name_of("gibtsnicht"), "", "name_of('gibtsnicht') ist ''")
	check_eq(CarCatalog.color_of("drifter"), Color(0.95, 0.75, 0.15), "color_of('drifter') ist Color(0.95, 0.75, 0.15)")
	check_eq(CarCatalog.color_of("gibtsnicht"), Color.WHITE, "color_of('gibtsnicht') ist Color.WHITE")


func test_allround_aendert_nichts() -> void:
	var p := CarPhysics.new()
	CarCatalog.apply("allround", p)
	check_eq(p.grip, 30.0, "p.grip ist 30.0")
	check_eq(p.traction_limit, 1400.0, "p.traction_limit ist 1400.0")


func test_grip_ist_griffiger() -> void:
	var p := CarPhysics.new()
	CarCatalog.apply("grip", p)
	check_eq(p.grip, 34.0, "p.grip ist 34.0")
	check_eq(p.traction_limit, 1700.0, "p.traction_limit ist 1700.0")
	check_eq(p.max_speed, 740.0, "p.max_speed ist 740.0")


func test_drifter_rutscht_eher() -> void:
	var p := CarPhysics.new()
	CarCatalog.apply("drifter", p)
	check_eq(p.traction_limit, 1150.0, "p.traction_limit ist 1150.0")
	check_eq(p.handbrake_grip, 0.45, "p.handbrake_grip ist 0.45")
	check_eq(p.drift_steer_bonus, 1.6, "p.drift_steer_bonus ist 1.6")
