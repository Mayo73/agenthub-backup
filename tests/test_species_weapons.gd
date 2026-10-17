extends "res://tests/base_test.gd"


func test_stachelkugel() -> void:
	var t := SpeciesWeapons.spike_tips("stachelkugel", Vector2.ZERO, 0.0, 18.0)
	check_eq(t.size(), 8, "stachelkugel hat 8 Spitzen")
	check(t[0] == Vector2(27, 0), "erste Spitze bei (27, 0)")
	check(t[2].is_equal_approx(Vector2(0, 27)), "dritte Spitze bei (0, 27)")


func test_stachelkugel_verschoben() -> void:
	var t := SpeciesWeapons.spike_tips("stachelkugel", Vector2(100, 50), 0.0, 18.0)
	check(t[0] == Vector2(127, 50), "Stachel bei verschobenem Zentrum")


func test_hornjaeger() -> void:
	var t := SpeciesWeapons.spike_tips("hornjaeger", Vector2.ZERO, 0.0, 40.0)
	check_eq(t.size(), 2, "hornjaeger hat 2 Stacheln")
	var expected := PartGeometry.world_point(Vector2.ZERO, 0.0, 40.0, Vector2(0.7, 0.7).normalized() * 1.6)
	check(t[0].is_equal_approx(expected), "erste Spitze von hornjaeger berechnet sich korrekt")


func test_ohne_stacheln() -> void:
	var n := SpeciesWeapons.spike_tips("blasenling", Vector2.ZERO, 0.0, 12.0).size()
	check_eq(n, 0, "blasenling hat keine Stachelspitzen")


func test_gift() -> void:
	check(SpeciesWeapons.has_poison("giftling"), "giftling hat Gift")
	check(!SpeciesWeapons.has_poison("schnapper"), "schnapper hat kein Gift")
	check_eq(SpeciesWeapons.count_part("giftling", "gift"), 2, "giftling hat 2 Giftdrüsen")


func test_elektro() -> void:
	check(SpeciesWeapons.has_electric("zitterzelle"), "zitterzelle hat Elektroorgan")
	check(!SpeciesWeapons.has_electric("giftling"), "giftling hat kein Elektroorgan")
