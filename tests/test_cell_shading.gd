extends "res://tests/base_test.gd"

func test_schatten() -> void:
	var actual := CellShading.shadow_offset(10.0, 0.0)
	check(actual.is_equal_approx(Vector2(1.2, 1.6)), "Schattenversatz bei radius=10 und rotation=0")

func test_schatten_gedreht() -> void:
	var actual := CellShading.shadow_offset(10.0, PI / 2.0)
	check(actual.is_equal_approx(Vector2(1.6, -1.2)), "Schattenversatz bei radius=10 und rotation=PI/2")

func test_glanzlicht() -> void:
	var actual_center := CellShading.highlight_center(10.0, 0.0)
	check(actual_center.is_equal_approx(Vector2(-3.5, -4.0)), "Glanzlichtmitte bei radius=10 und rotation=0")
	check_eq(
		CellShading.highlight_radius(10.0),
		2.8,
		"Glanzlichtradius bei radius=10"
	)

func test_glanzfarbe() -> void:
	var l := CellLook.new()
	l.color = Color(0, 0, 0)
	check(
		CellShading.highlight_color(l).is_equal_approx(Color(0.6, 0.6, 0.6, 0.35)),
		"Glanzlichtfarbe bei schwarzer Zellfarbe"
	)
