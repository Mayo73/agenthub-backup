extends "res://tests/base_test.gd"


func test_maulpunkt() -> void:
	var p1 := MouthContact.mouth_point(Vector2.ZERO, 0.0, 10.0)
	check_eq(p1.x, 10.0, "m_punkt_0_deg")
	check_eq(p1.y, 0.0, "m_punkt_0_deg_y")

	var p2 := MouthContact.mouth_point(Vector2(5, 5), PI / 2, 10.0)
	check(p2.is_equal_approx(Vector2(5, 15)), "m_punkt_90_deg")


func test_beruehren() -> void:
	check(MouthContact.touches(Vector2.ZERO, 4.0, Vector2(8, 0), 5.0), "touches_true")
	check(not MouthContact.touches(Vector2.ZERO, 4.0, Vector2(10, 0), 5.0), "touches_false")
