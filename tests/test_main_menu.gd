extends "res://tests/base_test.gd"

var menu: Control

func setup() -> void:
	menu = load("res://scenes/main_menu.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(menu)

func teardown() -> void:
	menu.free()
	menu = null

func test_knoepfe() -> void:
	check_eq(menu.start_button.text, "Rennen starten", "Start-Knopf Text")
	check_eq(menu.settings_button.text, "Einstellungen", "Settings-Knopf Text")
	check(menu.settings_button.disabled, "Settings-Knopf ist ausgegraut")
	check_eq(menu.quit_button.text, "Beenden", "Quit-Knopf Text")

func test_knoepfe_verbunden() -> void:
	check(menu.start_button.pressed.is_connected(menu.start_game), "Start-Knopf mit start_game verbunden")
	check(menu.quit_button.pressed.is_connected(menu.quit_game), "Quit-Knopf mit quit_game verbunden")

func test_rennszene_existiert() -> void:
	check(ResourceLoader.exists(menu.GAME_SCENE), "Rennszene existiert")
