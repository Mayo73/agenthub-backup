extends "res://tests/base_test.gd"


func test_im_wasser() -> void:
	check_eq(FishWorld.clamp_to_water(Vector3(0, -20, 0)), Vector3(0, -20, 0), "Lage im Wasser bleibt gleich")
	check_eq(FishWorld.clamp_to_water(Vector3(0, 5, 0)), Vector3(0, -0.5, 0), "nicht über die Oberfläche")
	check_eq(FishWorld.clamp_to_water(Vector3(0, -80, 0)), Vector3(0, -FishWorld.DEPTH + 0.5, 0), "nicht unter den Boden")
	check_eq(FishWorld.clamp_to_water(Vector3(200, -10, -200)), Vector3(150, -10, -150), "nicht über die Ränder")


func test_tiefe() -> void:
	check_eq(FishWorld.depth_of(Vector3(3, -12.5, 1)), 12.5, "Tiefe unter der Oberfläche")
