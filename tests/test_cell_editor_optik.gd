extends "res://tests/base_test.gd"

var editor: CellEditor


func setup() -> void:
	editor = CellEditor.new()


func teardown() -> void:
	editor.free()


func test_hintergrundbild() -> void:
	check(editor.background_image.texture != null, "Hintergrundbild existiert")
	check_eq(editor.background_image.texture.get_width(), 1920, "Hintergrundbild Breite ist 1920")
	check(editor.background_image.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Hintergrundbild ignoriert Maus-Eingaben")


func test_reihenfolge() -> void:
	check(editor.view_layer.get_child(1) == editor.background_image, "BackgroundImage ist Kind 1 von view_layer")
	check(editor.view_layer.get_child(2) == editor.canvas, "Canvas ist Kind 2 von view_layer")
