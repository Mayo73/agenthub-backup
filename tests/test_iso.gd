extends "res://tests/base_test.gd"


func test_welt_x_zeigt_nach_rechts_unten() -> void:
	check_eq(Iso.to_screen(Vector2(1, 0)), Vector2(1, 0.5))


func test_welt_y_zeigt_nach_links_unten() -> void:
	check_eq(Iso.to_screen(Vector2(0, 1)), Vector2(-1, 0.5))


func test_hin_und_zurueck() -> void:
	var p := Vector2(123.5, -48.25)
	check(Iso.to_world(Iso.to_screen(p)).is_equal_approx(p), "to_world(to_screen(p)) ergibt p")
