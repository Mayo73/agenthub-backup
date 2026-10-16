extends "res://tests/base_test.gd"

const P := "user://test_main_platz_"

var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)
	main.slot_prefix = P


func teardown() -> void:
	for slot in range(1, 4):
		var path := SaveSlots.path_for(slot, P)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	main.free()


func test_neue_partie_fragt() -> void:
	main.main_menu.herbivore_button.pressed.emit()
	check(main.slot_menu.visible, "SlotMenu soll sichtbar sein")
	check(main.in_menu, "in_menu soll true sein")


func test_neue_partie_im_platz() -> void:
	main.ask_slot_new(Diet.FLEISCHFRESSER)
	main.slot_menu.slot_buttons[1].pressed.emit()
	check(not main.in_menu, "in_menu sollte false sein")
	check(main.player.diet == Diet.FLEISCHFRESSER, "Fleischfresser muss gesetzt sein")
	check(main.save_path == SaveSlots.path_for(2, P), "save_path soll Pfad von Platz 2 sein")
	check(FileAccess.file_exists(SaveSlots.path_for(2, P)), "Spielstand-Datei soll existieren")


func test_fortsetzen() -> void:
	main.ask_slot_new(Diet.PFLANZENFRESSER)
	main.slot_menu.slot_buttons[0].pressed.emit()
	main.progress.dna = 9
	main.save_now()
	main.back_to_menu()
	main.progress.dna = 0
	main.ask_slot_continue()
	main.slot_menu.slot_buttons[0].pressed.emit()
	check(main.progress.dna == 9, "DNA muss geladen sein")
	check(not main.in_menu, "in_menu soll false sein")


func test_fortsetzen_moeglich() -> void:
	main.ask_slot_new(Diet.PFLANZENFRESSER)
	main.slot_menu.slot_buttons[2].pressed.emit()
	main.back_to_menu()
	check(not main.main_menu.continue_button.disabled, "Fortsetzen darf nicht disabled sein")
