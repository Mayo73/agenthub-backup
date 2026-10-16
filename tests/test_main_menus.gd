extends "res://tests/base_test.gd"

const PATH := "user://test_menue_spielstand.json"
const TEST_P := "user://test_menu_slots_"

var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)
	main.save_path = PATH
	main.slot_prefix = TEST_P
	# Für Slot-basierte Tests
	if FileAccess.file_exists(SaveSlots.path_for(1, TEST_P)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveSlots.path_for(1, TEST_P)))


func teardown() -> void:
	main.free()
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	for slot in range(1, 4):
		var path := SaveSlots.path_for(slot, TEST_P)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func test_start_im_menue() -> void:
	check(main.in_menu, "nicht im Menü")
	check(main.main_menu.visible, "MainMenu nicht sichtbar")
	check(not main.world.visible, "world soll unsichtbar sein")
	check(main.world.process_mode == Node.PROCESS_MODE_DISABLED, "world darf nicht laufen")


func test_neue_partie() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	check(not main.in_menu, "in_menu sollte false sein")
	check(main.world.visible, "world soll sichtbar sein")

	main.start_new(Diet.FLEISCHFRESSER)
	check(main.player.diet == Diet.FLEISCHFRESSER, "Fleischfresser muss gesetzt sein")


func test_pause() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
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
	main.start_new(Diet.PFLANZENFRESSER)
	main.progress.dna = 5
	main.save_path = SaveSlots.path_for(1, TEST_P)
	main.save_now()
	main.back_to_menu()

	check(main.in_menu, "in_menu soll true sein")
	check(not main.paused, "paused soll false sein")
	check(FileAccess.file_exists(SaveSlots.path_for(1, TEST_P)), "Spielstand muss existieren")
	check(not main.main_menu.continue_button.disabled, "Fortsetzen darf nicht disabled sein")


func test_fortsetzen() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	main.progress.dna = 9
	main.save_path = SaveSlots.path_for(1, TEST_P)
	main.save_now()
	main.back_to_menu()
	main.progress.dna = 0
	main.slot_prefix = TEST_P

	# Continue-Button drücken (öffnet SlotMenu), dann Platz 1 wählen
	main.main_menu.continue_button.pressed.emit()
	main.slot_menu.slot_buttons[0].pressed.emit()

	check(not main.in_menu, "in_menu soll false sein")
	check(main.progress.dna == 9, "DNA muss geladen sein")
