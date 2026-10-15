extends "res://tests/base_test.gd"

const TEST_PATH := "user://test_menu_einstellungen.json"
var menu: Control


func setup() -> void:
	menu = load("res://scenes/settings_menu.tscn").instantiate()
	menu.settings_path = TEST_PATH
	(Engine.get_main_loop() as SceneTree).root.add_child(menu)


func teardown() -> void:
	menu.free()
	menu = null
	AudioServer.set_bus_volume_db(0, 0.0)
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))


func test_startwerte() -> void:
	check(absf(menu.volume_slider.value - 0.8) < 0.001, "volume_slider sollte 0.8 sein")
	check(menu.fullscreen_box.button_pressed == false, "fullscreen_box sollte falsch sein")


func test_lautstaerke_aendern() -> void:
	menu.volume_slider.value = 0.5
	check(menu.settings.volume == 0.5, "settings.volume sollte 0.5 sein")
	check(absf(AudioServer.get_bus_volume_db(0) - linear_to_db(0.5)) < 0.01, "AudioServer sollte aktualisiert werden")


func test_speichern() -> void:
	menu.volume_slider.value = 0.3
	menu.save_settings()
	var loaded := UserSettings.load_from(TEST_PATH)
	check(absf(loaded.volume - 0.3) < 0.001, "gespeicherter volume sollte 0.3 sein")


func test_knoepfe_verbunden() -> void:
	check(menu.back_button.pressed.is_connected(menu.go_back), "back_button sollte mit go_back verbunden sein")
	check(ResourceLoader.exists(menu.MENU_SCENE), "MENU_SCENE sollte existieren")
