extends "res://tests/base_test.gd"
## Tests für Titelbild im Hauptmenü (T-0162)

var menu: MainMenu


func setup() -> void:
	menu = MainMenu.new()


func teardown() -> void:
	menu.free()


func test_bild() -> void:
	check(menu.title_image.texture != null, "title_image.texture ist null")
	check_eq(menu.title_image.texture.get_width(), 1920, "Bildbreite ist nicht 1920")


func test_reihenfolge() -> void:
	check(menu.get_child(1) == menu.title_image, "title_image ist nicht Child 1")
	check(menu.get_child(2) == menu.box, "box ist nicht Child 2")


func test_klicks_gehen_durch() -> void:
	check(menu.title_image.mouse_filter == Control.MOUSE_FILTER_IGNORE, "mouse_filter ist nicht MOUSE_FILTER_IGNORE")
	check_eq(menu.box.get_child_count(), 6, "VBoxContainer hat nicht 6 Kinder")
