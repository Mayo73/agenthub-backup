extends "res://tests/base_test.gd"

var combo: ComboCounter


func setup() -> void:
	combo = ComboCounter.new()


func teardown() -> void:
	combo = null


func test_erste_muenze_ist_eins() -> void:
	var result := combo.register_coin(0.0)
	check_eq(result, 1, "erste Münze ergibt Multiplikator 1")


func test_schnelle_muenzen_steigern() -> void:
	combo.register_coin(0.0)
	check_eq(combo.register_coin(1.0), 2, "zweite nach 1s → 2")
	check_eq(combo.register_coin(2.0), 3, "dritte nach 1s → 3")


func test_maximum_ist_fuenf() -> void:
	combo.register_coin(0.0)
	combo.register_coin(1.0)
	combo.register_coin(2.0)
	combo.register_coin(3.0)
	combo.register_coin(4.0)
	var result := combo.register_coin(5.0)
	check_eq(result, 5, "Multiplikator bleibt bei 5")


func test_pause_setzt_zurueck() -> void:
	combo.register_coin(0.0)
	combo.register_coin(1.0)
	var result := combo.register_coin(3.0)
	check_eq(result, 1, "Pause > COMBO_WINDOW setzt Kombo auf 1")


func test_reset() -> void:
	combo.register_coin(0.0)
	combo.register_coin(1.0)
	combo.reset()
	var result := combo.register_coin(1.5)
	check_eq(result, 1, "nach reset zählt erste Münze wieder als 1")
