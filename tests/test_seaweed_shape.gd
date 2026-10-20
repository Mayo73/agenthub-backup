extends "res://tests/base_test.gd"


func test_wirbelsaeule() -> void:
	var points := SeaweedShape.spine(10.0, 0.0)
	check_eq(points.size(), 9, "9 Punkte bei 8 Segmenten")
	check_eq(points[0], Vector3.ZERO, "erster Punkt am Fuß")
	check(points[8].is_equal_approx(Vector3(0, 10, 0)), "letzter Punkt an der Spitze")


func test_biegung() -> void:
	var points := SeaweedShape.spine(10.0, 0.5)
	check(is_equal_approx(points[8].x, 1.75), "Spitze um 1,75 m gebogen")
	check(is_equal_approx(points[4].x, 0.4375), "Mitte um 0,4375 m gebogen")


func test_breite() -> void:
	check(is_equal_approx(SeaweedShape.width_at(0.0, 0.35), 0.35), "volle Breite am Fuß")
	check(is_equal_approx(SeaweedShape.width_at(1.0, 0.35), 0.07), "schmal an der Spitze")


func test_mesh() -> void:
	var mesh := SeaweedShape.build_mesh(5.0, 0.3)
	check_eq(mesh.get_surface_count(), 1, "eine Oberfläche")
	var vertices: PackedVector3Array = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	check(vertices.size() >= SeaweedShape.SEGMENTS * 6, "mindestens 6 Eckpunkte je Segment")
