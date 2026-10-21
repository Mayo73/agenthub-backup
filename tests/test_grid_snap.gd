extends "res://tests/base_test.gd"


func test_2d() -> void:
	var r1 := GridSnap.snap(Vector2(1.26, -0.74), 0.5)
	check_eq(r1, Vector2(1.5, -0.5), "snap mit Schrittweite 0.5")

	var r2 := GridSnap.snap(Vector2(3.3, 1.0), 0.0)
	check_eq(r2, Vector2(3.3, 1.0), "snap bei Schrittweite <= 0 unverändert")


func test_3d() -> void:
	var r := GridSnap.snap_3d(Vector3(0.24, 0.26, -0.26), 0.5)
	check_eq(r, Vector3(0, 0.5, -0.5), "snap_3d mit Schrittweite 0.5")


func test_winkel() -> void:
	var r1 := GridSnap.snap_angle(52.0, 15.0)
	check_eq(r1, 45.0, "snap_angle 52 auf 15er Raster ergibt 45")

	var r2 := GridSnap.snap_angle(-10.0, 15.0)
	check_eq(r2, 345.0, "snap_angle -10 auf 15er Raster ergibt 345")

	var r3 := GridSnap.snap_angle(359.0, 15.0)
	check_eq(r3, 0.0, "snap_angle 359 auf 15er Raster ergibt 0")
