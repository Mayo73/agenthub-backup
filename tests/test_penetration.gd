extends "res://tests/base_test.gd"


func test_durch() -> void:
	var speed: float = Penetration.exit_speed(300.0, 0.1, 1000.0)
	check_eq(speed, 200.0, "exit_speed bei Durchschlagen")

	var penetrates: bool = Penetration.passes(300.0, 0.1, 1000.0)
	check(penetrates, "passes bei Durchschlagen")


func test_stecken() -> void:
	var speed: float = Penetration.exit_speed(50.0, 0.1, 1000.0)
	check_eq(speed, 0.0, "exit_speed wenn steckengeblieben")

	var penetrates: bool = Penetration.passes(50.0, 0.1, 1000.0)
	check(not penetrates, "passes wenn steckengeblieben")


func test_schaden() -> void:
	var factor: float = Penetration.damage_factor(300.0, 200.0)
	check(abs(factor - 0.6667) < 0.001, "damage_factor normalfall")

	factor = Penetration.damage_factor(0.0, 10.0)
	check_eq(factor, 0.0, "damage_factor bei entry_speed <= 0")

	factor = Penetration.damage_factor(100.0, 150.0)
	check_eq(factor, 1.0, "damage_factor bei exit > entry")
