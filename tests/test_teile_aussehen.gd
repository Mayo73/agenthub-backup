extends "res://tests/base_test.gd"

func test_spielerzelle() -> void:
	var src := FileAccess.get_file_as_string("res://scripts/player_cell.gd")
	check(not src.contains("PartShapes"), "player_cell.gd enthält keine PartShapes mehr")
	check(src.contains("PartLooks.placed(part, radius)"), "player_cell.gd verwendet PartLooks.placed(part, radius)")

func test_editor() -> void:
	var src := FileAccess.get_file_as_string("res://scripts/cell_editor_canvas.gd")
	check(not src.contains("PartShapes"), "cell_editor_canvas.gd enthält keine PartShapes mehr")
	check(src.contains("PartLooks.placed(part, SCALE)"), "cell_editor_canvas.gd verwendet PartLooks.placed(part, SCALE)")
