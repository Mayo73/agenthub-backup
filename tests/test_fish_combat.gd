extends "res://tests/base_test.gd"


func test_biss_trifft() -> void:
	check(FishCombat.bite_hits(Vector3.ZERO, Vector3(0, 0, 1.0), 0.6), "Biss trifft bei Distanz 1.0 <= 0.6 + 0.4")
	check(not FishCombat.bite_hits(Vector3.ZERO, Vector3(0, 0, 1.01), 0.6), "Biss trifft nicht bei Distanz 1.01 > 0.6 + 0.4")


func test_abwehr() -> void:
	var b := FishBuild.new()
	check_eq(FishCombat.damage_to_player(20.0, b), 20.0, "ohne Stacheln wird kein Schaden abgezogen")
	b.upgrade("stacheln")
	b.upgrade("stacheln")
	check_eq(FishCombat.damage_to_player(20.0, b), 14.0, "nach zwei Stufen beträgt der erhaltene Schaden 14.0")


func test_stacheln_verletzen() -> void:
	check_eq(FishCombat.spike_reflect(FishBuild.new()), 0.0, "ohne Stacheln gibt es keinen Rückstoßschaden")
	var b := FishBuild.new()
	b.upgrade("stacheln")
	b.upgrade("stacheln")
	b.upgrade("stacheln")
	check_eq(FishCombat.spike_reflect(b), 18.0, "nach drei Stufen beträgt der Rückstoßschaden 18.0")
