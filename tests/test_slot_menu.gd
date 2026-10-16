extends "res://tests/base_test.gd"

const P := "user://test_menue_platz_"
var menu: SlotMenu


func setup() -> void:
	menu = SlotMenu.new()
	menu.prefix = P


func teardown() -> void:
	for slot in range(1, 4):
		var path := SaveSlots.path_for(slot, P)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	menu.free()


func test_aufbau() -> void:
	check(not menu.visible, "menu initially nicht sichtbar")
	check_eq(menu.slot_buttons.size(), 3, "slot_buttons.size() ist 3")
	check_eq(menu.box.get_child_count(), 5, "box.get_child_count() ist 5 (Title + 3 Buttons + Back)")


func test_neue_partie() -> void:
	menu.open("Neue Partie", false)
	check(menu.visible, "menu sichtbar nach open")
	check_eq(menu.title_label.text, "Neue Partie", "title_label.text ist 'Neue Partie'")
	check_eq(menu.slot_buttons[0].text, "Platz 1: Leer", "slot_buttons[0].text ist 'Platz 1: Leer'")
	check(not menu.slot_buttons[0].disabled, "slot_buttons[0].disabled falsch (false)")


func test_fortsetzen() -> void:
	SaveGame.write_file(SaveSlots.path_for(3, P), {"stage": 0, "dna": 5, "diet": Diet.FLEISCHFRESSER})
	menu.open("Fortsetzen", true)
	check(menu.slot_buttons[0].disabled, "slot_buttons[0].disabled wahr (unbesetzt)")
	check(not menu.slot_buttons[2].disabled, "slot_buttons[2].disabled falsch (besetzt)")
	check_eq(menu.slot_buttons[2].text, "Platz 3: Größe 1 · 5 DNA · Fleischfresser", "slot_buttons[2].text korrekt")


func test_waehlen() -> void:
	var got: Array = []
	menu.slot_chosen.connect(func(s: int) -> void: got.append(s))
	menu.open("x", false)
	menu.slot_buttons[1].pressed.emit()
	check_eq(got.size(), 1, "ein Signal empfangen")
	check_eq(got[0], 2, "slot_chosen mit 2")
	check(not menu.visible, "menu nach Wahl nicht sichtbar")


func test_zurueck() -> void:
	var got: Array = []
	menu.closed.connect(func() -> void: got.append(1))
	menu.open("x", false)
	menu.back_button.pressed.emit()
	check_eq(got.size(), 1, "closed Signal empfangen")
	check(not menu.visible, "menu nach Zurück nicht sichtbar")
