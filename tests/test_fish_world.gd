extends "res://tests/base_test.gd"


func test_im_wasser() -> void:
	check_eq(FishWorld.clamp_to_water(Vector3(0, -20, 0)), Vector3(0, -20, 0), "Lage im Wasser bleibt gleich")
	check_eq(FishWorld.clamp_to_water(Vector3(0, 5, 0)), Vector3(0, -0.5, 0), "nicht über die Oberfläche")
	check_eq(FishWorld.clamp_to_water(Vector3(0, -80, 0)), Vector3(0, -FishWorld.DEPTH + 0.5, 0), "nicht unter den Boden")
	check_eq(FishWorld.clamp_to_water(Vector3(200, -10, -200)), Vector3(150, -10, -150), "nicht über die Ränder")


func test_tiefe() -> void:
	check_eq(FishWorld.depth_of(Vector3(3, -12.5, 1)), 12.5, "Tiefe unter der Oberfläche")


func test_tiefenanteil() -> void:
	check_eq(FishWorld.depth_ratio(0.0), 0.0, "Oberfläche hat Verhältnis 0.0")
	check_eq(FishWorld.depth_ratio(30.0), 0.5, "Mitte hat Verhältnis 0.5")
	check_eq(FishWorld.depth_ratio(-5.0), 0.0, "Negative Tiefe clamped auf 0.0")
	check_eq(FishWorld.depth_ratio(90.0), 1.0, "Doppelt so tief wie DEPTH clamped auf 1.0")


func test_wasserfarbe() -> void:
	check_eq(FishWorld.water_color_at(0.0), FishWorld.WATER_COLOR, "Oberfläche hat WATER_COLOR")
	var boden_farbe := FishWorld.water_color_at(FishWorld.DEPTH)
	var deep := FishWorld.DEEP_COLOR
	check(is_equal_approx(boden_farbe.r, deep.r) and is_equal_approx(boden_farbe.g, deep.g) and is_equal_approx(boden_farbe.b, deep.b) and boden_farbe.a == deep.a, "Boden hat DEEP_COLOR")
	check(FishWorld.water_color_at(40.0).get_luminance() < FishWorld.water_color_at(10.0).get_luminance(), "Tiefer ist dunkler")


func test_licht() -> void:
	check_eq(FishWorld.ambient_energy_at(0.0), 0.9, "Oberfläche hat Lichtstärke 0.9")
	check_eq(FishWorld.ambient_energy_at(60.0), 0.35, "Boden hat Lichtstärke 0.35")
	check_eq(FishWorld.ambient_energy_at(30.0), 0.625, "Mitte hat Durchschnittslichtstärke 0.625")
