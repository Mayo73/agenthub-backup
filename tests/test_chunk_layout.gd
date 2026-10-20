extends "res://tests/base_test.gd"


func test_gleich() -> void:
	var layout1 := ChunkLayout.new(Vector2i(3, -2), SeafloorHeight.new())
	var layout2 := ChunkLayout.new(Vector2i(3, -2), SeafloorHeight.new())

	check_eq(layout1.items.size(), layout2.items.size(), "Anzahl muss gleich sein")
	if layout1.items.size() > 0:
		check_eq(layout1.items[0]["position"], layout2.items[0]["position"], "Erste Position muss gleich sein")


func test_verschieden() -> void:
	var layout_a := ChunkLayout.new(Vector2i(0, 0), SeafloorHeight.new())
	var layout_b := ChunkLayout.new(Vector2i(1, 0), SeafloorHeight.new())

	check(layout_a.items[0]["position"] != layout_b.items[0]["position"], "Erste Positionen müssen verschieden sein")


func test_in_kachel() -> void:
	var layout := ChunkLayout.new(Vector2i(-1, 2), SeafloorHeight.new())

	for item in layout.items:
		var pos: Vector3 = item["position"]
		check(pos.x >= -64.0 and pos.x <= 0.0, "x muss zwischen -64 und 0 liegen")
		check(pos.z >= 128.0 and pos.z <= 192.0, "z muss zwischen 128 und 192 liegen")


func test_auf_dem_boden() -> void:
	var floor := SeafloorHeight.new()
	var layout := ChunkLayout.new(Vector2i(0, 0), floor)

	for item in layout.items:
		var pos: Vector3 = item["position"]
		var expected_y := floor.height_at(pos.x, pos.z)
		check_eq(pos.y, expected_y, "y jeder Position muss gleich height_at(x, z) sein")


func test_felsen() -> void:
	var layout := ChunkLayout.new(Vector2i(0, 0), SeafloorHeight.new())

	check_eq(layout.count("fels"), 5, "count('fels') muss 5 sein")
