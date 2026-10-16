extends "res://tests/base_test.gd"

const PATH := "user://test_menue_spielstand.json"

var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)
	main.save_path = PATH


func teardown() -> void:
	main.free()
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))


func test_start_im_menue() -> void:
	check(main.in_menu, "nicht im Menü")
	check(main.main_menu.visible, "MainMenu nicht sichtbar")
	check(not main.world.visible, "world soll unsichtbar sein")
	check(main.world.process_mode == Node.PROCESS_MODE_DISABLED, "world darf nicht laufen")


func test_neue_partie() -> void:
	main.main_menu.herbivore_button.pressed.emit()
	check(not main.in_menu, "in_menu sollte false sein")
	check(main.world.visible, "world soll sichtbar sein")

	main.main_menu.carnivore_button.pressed.emit()
	check(main.player.diet == Diet.FLEISCHFRESSER, "Fleischfresser muss gesetzt sein")


func test_pause() -> void:
	main.main_menu.herbivore_button.pressed.emit()
	main.toggle_pause()
	check(main.paused, "paused soll true sein")
	check(main.pause_menu.visible, "PauseMenu soll sichtbar sein")
	check(main.world.process_mode == Node.PROCESS_MODE_DISABLED, "world darf nicht laufen")

	main.pause_menu.resume_button.pressed.emit()
	check(not main.paused, "paused soll false sein")
	check(not main.pause_menu.visible, "PauseMenu soll unsichtbar sein")


func test_keine_pause_im_menue() -> void:
	main.toggle_pause()
	check(not main.paused, "paused soll false bleiben")


func test_zurueck_ins_menue() -> void:
	main.main_menu.herbivore_button.pressed.emit()
	main.toggle_pause()
	main.pause_menu.main_menu_button.pressed.emit()

	check(main.in_menu, "in_menu soll true sein")
	check(not main.paused, "paused soll false sein")
	check(FileAccess.file_exists(PATH), "Spielstand muss existieren")
	check(not main.main_menu.continue_button.disabled, "Fortsetzen darf nicht disabled sein")


func test_fortsetzen() -> void:
	main.main_menu.herbivore_button.pressed.emit()
	main.progress.dna = 9
	main.save_now()
	main.back_to_menu()
	main.progress.dna = 0
	main.main_menu.continue_button.pressed.emit()

	check(not main.in_menu, "in_menu soll false sein")
	check(main.progress.dna == 9, "DNA muss geladen sein")
