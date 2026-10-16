extends "res://tests/base_test.gd"
## Tests für das Öffnen der Einstellungen aus Haupt- und Pausemenü sowie Speichern beim Schließen.

const PATH := "user://test_main_einstellungen.cfg"
var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)
	main.settings_path = PATH


func teardown() -> void:
	main.free()
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))


func test_aus_hauptmenue() -> void:
	main.main_menu.settings_button.pressed.emit()
	check(main.settings_menu.visible, "Einstellungsmenü sichtbar")
	check(main.settings_menu.settings == main.settings, "settings-Referenz stimmt")


func test_aus_pause() -> void:
	main.main_menu.herbivore_button.pressed.emit()
	main.toggle_pause()
	main.pause_menu.settings_button.pressed.emit()
	check(main.settings_menu.visible, "Einstellungsmenü sichtbar")


func test_speichern_beim_schliessen() -> void:
	main.open_settings()
	main.settings_menu.music_slider.value = 0.4
	main.settings_menu.back_button.pressed.emit()
	check(FileAccess.file_exists(PATH), "Datei existiert nach Schließen")
	var s := UserSettings.new()
	s.load_from(PATH)
	check_eq(s.music_volume, 0.4, "music_volume korrekt gespeichert")
	check(not main.settings_menu.visible, "Einstellungsmenü verborgen")
