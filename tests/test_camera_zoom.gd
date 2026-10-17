extends "res://tests/base_test.gd"


func test_ziel() -> void:
	check_eq(CameraZoom.target_for_radius(12.0), 2.6, "Radius 12.0 ergibt Zoom 2.6")
	check_eq(CameraZoom.target_for_radius(24.0), 1.3, "Radius 24.0 ergibt Zoom 1.3")
	check_eq(CameraZoom.target_for_radius(6.0), 4.0, "Radius 6.0 ergibt Zoom 4.0 (Obergrenze)")
	check_eq(CameraZoom.target_for_radius(200.0), 0.3, "Radius 200.0 ergibt Zoom 0.3 (Untergrenze)")


func test_gleiten() -> void:
	check_eq(CameraZoom.smooth(1.0, 0.5, 0.0), 1.0, "delta=0 behält alten Wert")
	check_eq(CameraZoom.smooth(1.0, 0.5, 100.0), 0.5, "großer delta erreicht Ziel")
	var expected := exp(-1.0)
	check_eq(CameraZoom.smooth(1.0, 0.0, 0.5, 2.0), expected, "Formel mit rate=2.0 ergibt exp(-1)")
