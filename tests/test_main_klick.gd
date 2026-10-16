extends "res://tests/base_test.gd"

var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()


func test_menueknopf_klickt() -> void:
	main.pause_menu.settings_button.pressed.emit()
	check_eq(main.audio.last_played, "klick", "Menü-Knopf spielt Klick-Klang")


func test_einstellungen_klicken() -> void:
	main.settings_menu.back_button.pressed.emit()
	check_eq(main.audio.last_played, "klick", "Einstellungen-Knopf spielt Klick-Klang")


func test_editor_klingt() -> void:
	main.open_editor()
	main.editor.canvas.changed.emit()
	check_eq(main.audio.last_played, "teil_setzen", "Editor-Änderung spielt teil_setzen-Klang")

	main.editor.redo_button.pressed.emit()
	check_eq(main.audio.last_played, "klick", "Editor-Knopf spielt Klick-Klang")

	main.editor.cancel()
