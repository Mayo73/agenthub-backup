extends "res://tests/base_test.gd"

var rays: LightRays


func setup() -> void:
	rays = LightRays.new()


func teardown() -> void:
	rays.free()
	rays = null


func test_aufbau() -> void:
	check_eq(rays.rays.size(), LightRayLayout.COUNT, "rays array size")
	check_eq(rays.get_child_count(), LightRayLayout.COUNT, "child count")
	check_eq(rays.rays[0].position.y, -LightRayLayout.LENGTH * 0.5, "ray y position")


func test_folgt_kamera() -> void:
	rays.update(Vector3(10, -20, -5), 0.1)
	check_eq(rays.position.x, 10.0, "position x after update")
	check_eq(rays.position.y, 0.0, "position y after update")
	check_eq(rays.position.z, -5.0, "position z after update")


func test_neigung() -> void:
	rays.update(Vector3.ZERO, 0.0)
	check_eq(rays.rays[0].rotation.z, LightRayLayout.tilt(0.0, 0), "ray tilt")


func test_tiefe_schwaecher() -> void:
	rays.update(Vector3(0, -5, 0), 0.1)
	var oben := rays.material.albedo_color.a
	rays.update(Vector3(0, -40, 0), 0.1)
	check(rays.material.albedo_color.a < oben, "rays fade in depth")
