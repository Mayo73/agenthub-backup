extends "res://tests/base_test.gd"


func test_kugel() -> void:
	var result1: float = RayPick3D.ray_sphere(Vector3.ZERO, Vector3(0, 0, -1), Vector3(0, 0, -10), 2.0)
	check_eq(result1, 8.0, "Strahl trifft Kugel frontal")

	var result2: float = RayPick3D.ray_sphere(Vector3.ZERO, Vector3(0, 0, -1), Vector3(5, 0, -10), 2.0)
	check_eq(result2, -1.0, "Strahl seitlich an Kugel vorbei")


func test_box() -> void:
	var box: AABB = AABB(Vector3(-1, -1, -1), Vector3(2, 2, 2))
	var result1: float = RayPick3D.ray_aabb(Vector3(0, 0, 5), Vector3(0, 0, -1), box)
	check_eq(result1, 4.0, "Strahl trifft Box frontal")

	var result2: float = RayPick3D.ray_aabb(Vector3(0, 0, 5), Vector3(0, 0, 1), box)
	check_eq(result2, -1.0, "Strahl in falsche Richtung zur Box")


func test_innen() -> void:
	var box: AABB = AABB(Vector3(-1, -1, -1), Vector3(2, 2, 2))
	var result: float = RayPick3D.ray_aabb(Vector3.ZERO, Vector3(1, 0, 0), box)
	check_eq(result, 0.0, "Startpunkt liegt innerhalb der Box")


func test_auswahl() -> void:
	var targets: Array[Dictionary] = [
		{"id": "a", "center": Vector3(0, 0, -10), "radius": 1.0},
		{"id": "b", "box": AABB(Vector3(-1, -1, -6), Vector3(2, 2, 2))}
	]

	var dir: Vector3 = Vector3(0, 0, -1)
	var result1: Dictionary = RayPick3D.pick(Vector3.ZERO, dir, targets)
	check(result1.has("id"), "Ergebnis hat 'id'")
	check_eq(result1["id"], "b", "Box 'b' wird zuerst getroffen")
	check_eq(result1["distance"], 4.0, "Abstand ist 4.0")

	var dir2: Vector3 = Vector3(0, 1, 0)
	var result2: Dictionary = RayPick3D.pick(Vector3.ZERO, dir2, targets)
	check(result2.is_empty(), "Kein Treffer bei seitlichem Strahl")
