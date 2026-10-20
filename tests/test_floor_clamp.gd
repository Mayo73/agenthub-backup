extends "res://tests/base_test.gd"

var floor: SeafloorHeight


func setup() -> void:
	floor = SeafloorHeight.new(7)


func test_keine_raender() -> void:
	var p := Vector3(5000, -20, -7000)
	var result := FloorClamp.clamp_to_water(p, floor)
	check_eq(result.x, 5000.0, "x bleibt unverändert")
	check_eq(result.z, -7000.0, "z bleibt unverändert")


func test_oberflaeche() -> void:
	var p := Vector3(0.0, 3.0, 0.0)
	var result := FloorClamp.clamp_to_water(p, floor)
	check_eq(result.y, -FloorClamp.SURFACE_MARGIN, "y wird auf -SURFACE_MARGIN begrenzt")


func test_boden() -> void:
	var p := Vector3(10.0, -500.0, 20.0)
	var expected_y := floor.height_at(p.x, p.z) + FloorClamp.FLOOR_MARGIN
	var result := FloorClamp.clamp_to_water(p, floor)
	check_eq(result.y, expected_y, "y wird auf Bodenhöhe + FLOOR_MARGIN begrenzt")


func test_ueber_boden() -> void:
	var x := 10.0
	var z := 20.0
	var y := floor.height_at(x, z) + 4.0
	var p := Vector3(x, y, z)
	var result := FloorClamp.height_above_floor(p, floor)
	check_eq(result, 4.0, "Höhe über Boden ist korrekt")


func test_im_wasser() -> void:
	var x := 10.0
	var z := 20.0
	var bodenhoehe := floor.height_at(x, z)

	# 1 m über dem Boden → wahr
	var p1 := Vector3(x, bodenhoehe + 1.0, z)
	check(FloorClamp.is_in_water(p1, floor), "1 m über Boden ist im Wasser")

	# y = 2.0 (über der Oberfläche) → falsch
	var p2 := Vector3(10.0, 2.0, 20.0)
	check(not FloorClamp.is_in_water(p2, floor), "y = 2.0 ist nicht im Wasser")

	# 1 m unter dem Boden → falsch
	var p3 := Vector3(x, bodenhoehe - 1.0, z)
	check(not FloorClamp.is_in_water(p3, floor), "1 m unter Boden ist nicht im Wasser")
