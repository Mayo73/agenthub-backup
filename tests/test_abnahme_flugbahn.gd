extends "res://tests/base_test.gd"

var worst: float = 0.0

func test_bahn_2d() -> void:
	var proj := Projectile2D.new()
	proj.position = Vector2.ZERO
	proj.velocity = Vector2(20, -15)
	proj.lifetime = 10.0
	var walls: Array[Rect2] = []

	worst = 0.0
	for k in range(1, 241):
		proj.step(1.0 / 120.0, walls)
		var t: float = k * (1.0 / 120.0)
		var analytisch := Vector2(20.0 * t, -15.0 * t + 0.5 * 9.81 * t * t)
		var d: float = abs(proj.position.x - analytisch.x) + abs(proj.position.y - analytisch.y)
		if d > worst:
			worst = d
	check(worst <= 0.15, "Abweichung %.4f" % worst)

func test_bahn_3d() -> void:
	var proj := Projectile3D.new()
	proj.position = Vector3(0, 1, 0)
	proj.velocity = Vector3(10, 12, -5)
	proj.lifetime = 10.0
	var boxes: Array[AABB] = []

	worst = 0.0
	for k in range(1, 241):
		proj.step(1.0 / 120.0, boxes)
		var t: float = k * (1.0 / 120.0)
		var analytisch := Vector3(10.0 * t, 1.0 + 12.0 * t - 0.5 * 9.81 * t * t, -5.0 * t)
		var d: float = abs(proj.position.x - analytisch.x) + abs(proj.position.y - analytisch.y) + abs(proj.position.z - analytisch.z)
		if d > worst:
			worst = d
	check(worst <= 0.15, "Abweichung %.4f" % worst)

func test_noch_aktiv() -> void:
	var p2d := Projectile2D.new()
	p2d.position = Vector2.ZERO
	p2d.velocity = Vector2(20, -15)
	p2d.lifetime = 10.0
	var walls: Array[Rect2] = []
	for _k in range(240):
		p2d.step(1.0 / 120.0, walls)
	check(p2d.alive, "Projectile2D nach 240 Schritten nicht mehr aktiv")

	var p3d := Projectile3D.new()
	p3d.position = Vector3(0, 1, 0)
	p3d.velocity = Vector3(10, 12, -5)
	p3d.lifetime = 10.0
	var boxes: Array[AABB] = []
	for _k in range(240):
		p3d.step(1.0 / 120.0, boxes)
	check(p3d.alive, "Projectile3D nach 240 Schritten nicht mehr aktiv")
