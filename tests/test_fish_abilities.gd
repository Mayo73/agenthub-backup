extends "res://tests/base_test.gd"

var build := FishBuild.new()


func test_anfang() -> void:
	check_eq(FishAbilities.max_speed(build), 8.0, "max_speed")
	check_eq(FishAbilities.accel(build), 10.0, "accel")
	check_eq(FishAbilities.turn_rate(build), 1.8, "turn_rate")
	check_eq(FishAbilities.pitch_rate(build), 1.4, "pitch_rate")
	check_eq(FishAbilities.bite_damage(build), 10.0, "bite_damage")
	check_eq(FishAbilities.defense(build), 0.0, "defense")
	check_eq(FishAbilities.sight(build), 25.0, "sight")


func test_schwanz() -> void:
	build = FishBuild.new()
	build.upgrade("schwanz")
	build.upgrade("schwanz")
	check_eq(FishAbilities.max_speed(build), 12.0, "max_speed nach 2 Stufen Schwanz")
	check_eq(FishAbilities.accel(build), 15.0, "accel nach 2 Stufen Schwanz")


func test_flossen() -> void:
	build = FishBuild.new()
	build.upgrade("flossen")
	build.upgrade("flossen")
	build.upgrade("flossen")
	check_eq(FishAbilities.turn_rate(build), 3.0, "turn_rate nach 3 Stufen Flossen")
	check_eq(FishAbilities.pitch_rate(build), 2.45, "pitch_rate nach 3 Stufen Flossen")


func test_kiefer_stacheln_augen() -> void:
	build = FishBuild.new()
	build.upgrade("kiefer")
	build.upgrade("stacheln")
	build.upgrade("augen")
	check_eq(FishAbilities.bite_damage(build), 18.0, "bite_damage nach 1 Stufe Kiefer")
	check_eq(FishAbilities.defense(build), 0.15, "defense nach 1 Stufe Stacheln")
	check_eq(FishAbilities.sight(build), 35.0, "sight nach 1 Stufe Augen")


func test_anwenden() -> void:
	build = FishBuild.new()
	build.upgrade("schwanz")
	build.upgrade("flossen")
	var m := FishMotion.new()
	FishAbilities.apply(build, m)
	check_eq(m.max_speed, 10.0, "m.max_speed")
	check_eq(m.accel, 12.5, "m.accel")
	check_eq(m.turn_rate, 2.2, "m.turn_rate")
	check_eq(m.pitch_rate, 1.75, "m.pitch_rate")


func test_jede_stufe_schneller() -> void:
	var speeds := []
	for level in range(0, 4):
		build = FishBuild.new()
		for _i in range(level):
			build.upgrade("schwanz")
		speeds.append(FishAbilities.max_speed(build))
	check(speeds[0] < speeds[1], "Stufe 0 < Stufe 1")
	check(speeds[1] < speeds[2], "Stufe 1 < Stufe 2")
	check(speeds[2] < speeds[3], "Stufe 2 < Stufe 3")
