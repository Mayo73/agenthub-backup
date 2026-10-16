extends "res://tests/base_test.gd"


func test_weltpunkt() -> void:
	var result1 := PartGeometry.world_point(Vector2(10, 0), 0.0, 10.0, Vector2(1, 0))
	check_eq(result1.x, 20.0, "x-Koordinate ist 20")
	check_eq(result1.y, 0.0, "y-Koordinate ist 0")

	var result2 := PartGeometry.world_point(Vector2.ZERO, PI / 2, 10.0, Vector2(1, 0))
	check(result2.is_equal_approx(Vector2(0, 10)), "90°-Drehung ergibt (0, 10)")


func test_spitzen() -> void:
	var b := CellBuild.new()
	b.add_part("stachel", Vector2(-1, 0))
	b.add_part("geissel", Vector2(0, 1))
	var tips := WeaponRules.spike_tips(Vector2.ZERO, 0.0, 10.0, b)
	check_eq(tips.size(), 1, "nur ein Stachel liefert eine Spitze")
	check(tips[0].is_equal_approx(Vector2(-16, 0)), "Stachel bei (-1,0) ergibt Spitze bei (-16, 0)")


func test_spitze_gedreht() -> void:
	var b := CellBuild.new()
	b.add_part("stachel", Vector2(-1, 0))
	b.add_part("geissel", Vector2(0, 1))
	check(WeaponRules.spike_tips(Vector2.ZERO, PI, 10.0, b)[0].is_equal_approx(Vector2(16, 0)), "umgedreht zeigt Spitze nach rechts")


func test_lage_normalisiert() -> void:
	var b := CellBuild.new()
	b.add_part("stachel", Vector2(0, 0.5))
	b.add_part("geissel", Vector2(0, 1))
	check(WeaponRules.spike_tips(Vector2.ZERO, 0.0, 10.0, b)[0].is_equal_approx(Vector2(0, 16)), "Lage (0, 0.5) wird normalisiert zu Spitze bei (0, 16)")


func test_treffer() -> void:
	var b := CellBuild.new()
	b.add_part("stachel", Vector2(-1, 0))
	b.add_part("geissel", Vector2(0, 1))
	var tips := WeaponRules.spike_tips(Vector2.ZERO, 0.0, 10.0, b)

	check_eq(WeaponRules.spike_hits(tips, Vector2(-20, 0), 5.0), 1, "Treffer bei (-20, 0)")
	check_eq(WeaponRules.spike_hits(tips, Vector2(20, 0), 5.0), 0, "kein Treffer bei (20, 0)")
