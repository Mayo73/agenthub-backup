extends "res://tests/base_test.gd"


func test_kugeln() -> void:
	var overlap1: float = ShapeOverlap3D.spheres(Vector3.ZERO, 1.0, Vector3(1.5, 0, 0), 1.0)
	check_eq(overlap1, 0.5, "Überlappende Kugeln haben Eindringtiefe 0.5")
	var overlap2: float = ShapeOverlap3D.spheres(Vector3.ZERO, 1.0, Vector3(3, 0, 0), 1.0)
	check_eq(overlap2, 0.0, "Getrennte Kugeln haben Eindringtiefe 0")


func test_boxen() -> void:
	var a: AABB = AABB(Vector3(0, 0, 0), Vector3(2, 2, 2))
	var b: AABB = AABB(Vector3(0, 1.5, 0), Vector3(2, 2, 2))
	var result1: Vector3 = ShapeOverlap3D.boxes(a, b)
	check_eq(result1.x, 0.0, "Boxen-Überlappung x-Komponente")
	check_eq(result1.y, -0.5, "Boxen-Überlappung y-Komponente")
	check_eq(result1.z, 0.0, "Boxen-Überlappung z-Komponente")
	var c: AABB = AABB(Vector3(0, 0, 0), Vector3(1, 1, 1))
	var d: AABB = AABB(Vector3(5, 5, 5), Vector3(1, 1, 1))
	var result2: Vector3 = ShapeOverlap3D.boxes(c, d)
	check(result2 == Vector3.ZERO, "Getrennte Boxen ergeben ZERO")


func test_gleichstand() -> void:
	var a: AABB = AABB(Vector3(1, 1, 1), Vector3(2, 2, 2))
	var b: AABB = AABB(Vector3.ZERO, Vector3(2, 2, 2))
	var result: Vector3 = ShapeOverlap3D.boxes(a, b)
	check_eq(result.x, 1.0, "Gleichstand-Überlappung x-Komponente")
	check_eq(result.y, 0.0, "Gleichstand-Überlappung y-Komponente")
	check_eq(result.z, 0.0, "Gleichstand-Überlappung z-Komponente")


func test_kugel_box() -> void:
	var overlap: float = ShapeOverlap3D.sphere_box(Vector3(0, 2.5, 0), 1.0, AABB(Vector3(-1, 0, -1), Vector3(2, 2, 2)))
	check_eq(overlap, 0.5, "Kugel-Box-Überlappung hat Eindringtiefe 0.5")


func test_punkt() -> void:
	var in_result: bool = ShapeOverlap3D.point_in_box(Vector3(2, 2, 2), AABB(Vector3.ZERO, Vector3(2, 2, 2)))
	check(in_result, "Punkt auf Eckseite ist in Box")
	var out_result: bool = ShapeOverlap3D.point_in_box(Vector3(2.1, 0, 0), AABB(Vector3.ZERO, Vector3(2, 2, 2)))
	check(not out_result, "Punkt außerhalb ist nicht in Box")
