extends "res://tests/base_test.gd"

const PATH := "user://test_hinweise_spielstand.json"
var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)
	main.save_path = PATH


func teardown() -> void:
	main.free()
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))


func test_start() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	check_eq(main.hud.message_label.text, TutorialHints.TEXTS["bewegen"], "erster Hinweis beim Start")


func test_fressen() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	main.food.items.clear()
	main.food.add_item(Diet.PFLANZE, main.player.mouth_point())
	main.feed_player()
	check_eq(main.hud.message_label.text, TutorialHints.TEXTS["fressen"], "Hinweis beim Fressen")
	check(main.hints.shown.has("fressen"), "fressen ist im gespeicherten Hinweis-Set")


func test_nur_einmal() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	main.hint("gefahr")
	main.hud.show_message("x")
	main.hint("gefahr")
	check_eq(main.hud.message_label.text, "x", "zweiter gleicher Hinweis wird nicht gezeigt")


func test_gespeichert() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	main.hint("editor")
	var save_warp = main.save_now()
	check(save_warp, "Speichern erfolgreich")
	main.hints = TutorialHints.new()
	var load_ok = main.load_saved()
	check(load_ok, "Laden erfolgreich")
	check(main.hints.shown.has("editor"), "gezeigter Hinweis ist gespeichert und geladen")
	check(main.hints.shown.has("bewegen"), "bewegen ist auch gespeichert")
