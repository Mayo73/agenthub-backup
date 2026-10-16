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
	Controls.reset_defaults()
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


func test_tasten_angezeigt() -> void:
	check(menu.key_buttons.size() == Controls.ACTIONS.size(), "key_buttons size sollte ACTIONS size sein")
	check(menu.key_buttons["gas"].text == "W", "gas Button text sollte W sein")
	check(menu.get_node("Items/Keys") is GridContainer, "Items/Keys sollte GridContainer sein")


func test_taste_neu_belegen() -> void:
	menu.start_rebind("gas")
	check(menu.key_buttons["gas"].text == "Taste drücken …", "Button text sollte 'Taste drücken …' sein nach start_rebind")
	menu.handle_key(KEY_I)
	check(Controls.key_for("gas") == KEY_I, "key_for('gas') sollte KEY_I sein")
	check(menu.settings.keys["gas"] == KEY_I, "settings.keys['gas'] sollte KEY_I sein")
	check(menu.key_buttons["gas"].text == "I", "Button text sollte I sein nach Rebind")
	check(menu.waiting_action == "", "waiting_action sollte leer sein")


func test_escape_bricht_ab() -> void:
	menu.start_rebind("gas")
	menu.handle_key(KEY_ESCAPE)
	check(Controls.key_for("gas") == KEY_W, "key_for('gas') sollte unverändert KEY_W sein")
	check(menu.settings.keys.has("gas") == false, "settings.keys sollte 'gas' nicht haben nach Escape")
	check(menu.key_buttons["gas"].text == "W", "Button text sollte unverändert W sein")


func test_klick() -> void:
	check(menu.get_node("Click") is AudioStreamPlayer, "Click Node ist AudioStreamPlayer")
	check(menu.key_buttons["gas"].pressed.is_connected(menu.play_click), "key_buttons['gas'].pressed ist mit play_click verbunden")
