extends "res://tests/base_test.gd"

var grid: TileGrid


func setup() -> void:
	grid = TileGrid.new(1.0)


func test_setzen() -> void:
	grid.set_cell(Vector2i(2, 3), "gras")
	check_eq(grid.get_cell(Vector2i(2, 3)), "gras", "Kachel gesetzt und abgerufen")

	grid.set_cell(Vector2i(2, 3), "")
	check_eq(grid.get_cell(Vector2i(2, 3)), "", "leerer kind entfernt Kachel")


func test_umrechnen() -> void:
	var cam_grid: TileGrid = TileGrid.new(0.5)

	var cell: Vector2i = cam_grid.world_to_cell(Vector2(1.2, -0.1))
	check_eq(cell, Vector2i(2, -1), "world_to_cell ergibt erwarteten Wert")

	var world: Vector2 = cam_grid.cell_to_world(Vector2i(2, -1))
	check_eq(world, Vector2(1.25, -0.25), "cell_to_world ergibt Mittelpunkt")


func test_rechteck() -> void:
	grid = TileGrid.new(1.0)
	var count: int = grid.fill_rect(Vector2i(3, 1), Vector2i(0, 0), "stein")
	check_eq(count, 8, "fill_rect gibt Anzahl zurück")
	check_eq(grid.count("stein"), 8, "count ergibt 8 Steine")


func test_bereich() -> void:
	grid = TileGrid.new(1.0)
	grid.set_cell(Vector2i(-1, 0), "a")
	grid.set_cell(Vector2i(2, 4), "b")

	var rect: Rect2i = grid.used_rect()
	check_eq(rect, Rect2i(-1, 0, 4, 5), "used_rect für zwei Kacheln korrekt")

	grid = TileGrid.new(1.0)
	rect = grid.used_rect()
	check_eq(rect, Rect2i(), "used_rect für leeres Raster ergibt Rect2i()")


func test_speichern() -> void:
	grid = TileGrid.new(0.5)
	grid.set_cell(Vector2i(1, 2), "gras")
	grid.set_cell(Vector2i(3, 4), "stein")

	var d: Dictionary = grid.to_dict()
	var restored: TileGrid = TileGrid.from_dict(d)

	check_eq(restored.get_cell(Vector2i(1, 2)), "gras", "get_cell gras nach Restore")
	check_eq(restored.get_cell(Vector2i(3, 4)), "stein", "get_cell stein nach Restore")
	check_eq(restored.cell_size, 0.5, "cell_size aus JSON korrekt")
