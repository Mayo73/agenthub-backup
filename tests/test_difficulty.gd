extends "res://tests/base_test.gd"


func test_namen() -> void:
	check_eq(Difficulty.name_of(0), "Leicht", "Index 0 ist Leicht")
	check_eq(Difficulty.name_of(1), "Normal", "Index 1 ist Normal")
	check_eq(Difficulty.name_of(2), "Schwer", "Index 2 ist Schwer")


func test_faktoren() -> void:
	check_eq(Difficulty.damage_factor(0), 0.6, "Leicht Schadenfaktor ist 0.6")
	check_eq(Difficulty.damage_factor(Difficulty.NORMAL), 1.0, "Normal Schadenfaktor ist 1.0")
	check_eq(Difficulty.damage_factor(2), 1.5, "Schwer Schadenfaktor ist 1.5")


func test_grenzen() -> void:
	check_eq(Difficulty.clamp_index(-3), 0, "clamp_index(-3) ist 0")
	check_eq(Difficulty.clamp_index(7), 2, "clamp_index(7) ist 2")
	check_eq(Difficulty.damage_factor(9), 1.5, "damage_factor(9) ist 1.5")
	check_eq(Difficulty.name_of(-1), "Leicht", "name_of(-1) ist Leicht")
