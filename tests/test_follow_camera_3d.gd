extends "res://tests/base_test.gd"

var cam: FollowCamera3D

func setup() -> void:
	cam = FollowCamera3D.new()

func test_hinter_dem_ziel() -> void:
	var result: Vector3 = cam.desired(Vector3.ZERO, 0.0)
	check_eq(result.x, 0.0, "x sollte 0 sein")
	check_eq(result.y, 2.5, "y sollte 2.5 sein")
	check_eq(result.z, 6.0, "z sollte 6.0 sein")

func test_gedreht() -> void:
	var result: Vector3 = cam.desired(Vector3.ZERO, PI / 2.0)
	check_eq(result.x, -6.0, "x sollte -6 sein")
	check_eq(result.y, 2.5, "y sollte 2.5 sein")
	check_eq(result.z, 0.0, "z sollte 0 sein")

func test_weich() -> void:
	cam.snap(Vector3.ZERO, 0.0)
	var first_result: Vector3 = cam.update(Vector3(0.0, 0.0, -10.0), 0.0, 0.1)
	check(first_result.z > -4.0 && first_result.z < 6.0, "position.z sollte zwischen -4 und 6 liegen")

	for i in range(300):
		first_result = cam.update(Vector3(0.0, 0.0, -10.0), 0.0, 0.1)

	check(first_result.z > -5.0 && first_result.z < -3.0, "nach 300 Updates sollte position.z ungefähr -4 sein")

func test_sofort() -> void:
	cam.smoothing = 0.0
	var result: Vector3 = cam.update(Vector3(5.0, 0.0, 0.0), 0.0, 0.016)
	check_eq(result.x, 5.0, "x sollte 5 sein")
	check_eq(result.y, 2.5, "y sollte 2.5 sein")
	check_eq(result.z, 6.0, "z sollte 6 sein")

func test_blickpunkt() -> void:
	var result: Vector3 = cam.look_target(Vector3(1.0, 0.0, 2.0))
	check_eq(result.x, 1.0, "x sollte 1 sein")
	check_eq(result.y, 1.0, "y sollte 1 sein")
	check_eq(result.z, 2.0, "z sollte 2 sein")
