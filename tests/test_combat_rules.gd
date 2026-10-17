extends "res://tests/base_test.gd"


func test_biss_vorn() -> void:
	check(CombatRules.bite_hits(Vector2.ZERO, 0.0, 10.0, Vector2(20, 0), 8.0), "Biss von vorn trifft")


func test_biss_hinten_trifft_nicht() -> void:
	check(not CombatRules.bite_hits(Vector2.ZERO, 0.0, 10.0, Vector2(-20, 0), 8.0), "Biss von hinten trifft nicht")


func test_biss_zu_weit() -> void:
	check(not CombatRules.bite_hits(Vector2.ZERO, 0.0, 10.0, Vector2(30, 0), 8.0), "Zu weiter Biss trifft nicht")


func test_wer_beisst() -> void:
	check(CombatRules.can_bite(Diet.FLEISCHFRESSER), "Fleischfresser beißt")
	check(CombatRules.can_bite(Diet.ALLESFRESSER), "Allesfresser beißt")
	check(not CombatRules.can_bite(Diet.PFLANZENFRESSER), "Pflanzenfresser beißt nicht")


func test_schaden() -> void:
	check_eq(CombatRules.bite_damage(20.0, 18.0, 12.0), 30.0, "Größerer Angreifer mehr Schaden")
	check_eq(CombatRules.bite_damage(20.0, 12.0, 60.0), 10.0, "Kleinerer Angreifer weniger Schaden")
	check_eq(CombatRules.bite_damage(20.0, 60.0, 12.0), 40.0, "Sehr großer Angreifer max Schaden")


func test_fleischbrocken() -> void:
	var positions := CombatRules.meat_positions(Vector2.ZERO, 20.0)
	check_eq(positions.size(), 3, "Drei Fleischbrocken")
	check_eq(positions[0], Vector2(10.0, 0.0), "Erster Brocke bei (10, 0)")
	for pos in positions:
		check_eq(pos.distance_to(Vector2.ZERO), 10.0, "Abstand zum Ursprung ist 10.0")


func test_verschlucken() -> void:
	check(CombatRules.can_swallow(27.0, 12.0), "27er beißt 12er durch (größer)")
	check(CombatRules.can_swallow(24.0, 12.0), "24er beißt 12er durch (exakt Hälfte)")
	check(not CombatRules.can_swallow(18.0, 12.0), "18er beißt 12er nicht durch")
	check(CombatRules.can_swallow(60.0, 27.0), "60er beißt 27er durch")
	check(not CombatRules.can_swallow(40.0, 27.0), "40er beißt 27er nicht durch")
	check(not CombatRules.can_swallow(27.0, 27.0), "Gleiche Größe nicht verschluckbar")


func test_verschlucken_wert() -> void:
	check_eq(CombatRules.swallow_value(), 6, "Verschluckter Wert ist 3x2=6")
