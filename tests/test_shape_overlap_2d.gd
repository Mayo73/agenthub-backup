extends "res://tests/base_test.gd"


func test_kreise() -> void:
	var overlap1: float = ShapeOverlap2D.circles(Vector2(0, 0), 1.0, Vector2(1.5, 0), 1.0)
	check_eq(overlap1, 0.5, "Kreise überlappen um 0.5")

	var overlap2: float = ShapeOverlap2D.circles(Vector2(0, 0), 1.0, Vector2(3, 0), 1.0)
	check_eq(overlap2, 0.0, "Kreise berühren sich nicht")


func test_rechtecke() -> void:
	var push: Vector2 = ShapeOverlap2D.rects(Rect2(0, 0, 2, 2), Rect2(1.5, 0, 2, 2))
	check_eq(push, Vector2(-0.5, 0.0), "Rechtecke y-Überlappung")

	var no_push: Vector2 = ShapeOverlap2D.rects(Rect2(0, 0, 1, 1), Rect2(5, 5, 1, 1))
	check_eq(no_push, Vector2.ZERO, "Rechtecke ohne Überlappung")


func test_rechtecke_y() -> void:
	var push: Vector2 = ShapeOverlap2D.rects(Rect2(0, 1.8, 2, 2), Rect2(0, 0, 2, 2))
	check(is_equal_approx(push.y, 0.2) and is_equal_approx(push.x, 0.0), "Rechtecke x-Überlappung")


func test_kreis_rechteck() -> void:
	var overlap1: float = ShapeOverlap2D.circle_rect(Vector2(3, 1), 1.5, Rect2(0, 0, 2, 2))
	check_eq(overlap1, 0.5, "Kreis rechteck überlappt um 0.5")

	var overlap2: float = ShapeOverlap2D.circle_rect(Vector2(5, 5), 1.0, Rect2(0, 0, 2, 2))
	check_eq(overlap2, 0.0, "Kreis rechteck ohne Überlappung")


func test_punkt() -> void:
	var on_circle: bool = ShapeOverlap2D.point_in_circle(Vector2(1, 0), Vector2.ZERO, 1.0)
	check(on_circle, "Punkt auf Kreisrand gehört dazu")

	var off_circle: bool = ShapeOverlap2D.point_in_circle(Vector2(1.1, 0), Vector2.ZERO, 1.0)
	check(not off_circle, "Punkt außerhalb des Kreises")
