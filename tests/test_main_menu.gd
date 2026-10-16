extends "res://tests/base_test.gd"

var menu: MainMenu
var got: Array = []


func setup() -> void:
	menu = MainMenu.new()


func teardown() -> void:
	menu.free()


func test_knoepfe() -> void:
	check_eq(menu.box.get_child_count(), 6, "Anzahl der Kind-Nodes im Box-Container")
	check_eq(menu.herbivore_button.text, "Neue Partie: Pflanzenfresser", "Text des Herbivore-Buttons")
	check_eq(menu.quit_button.text, "Beenden", "Text des Quit-Buttons")


func test_neue_partie() -> void:
	menu.new_game.connect(func(d: String) -> void: got.append(d))
	menu.carnivore_button.pressed.emit()
	menu.herbivore_button.pressed.emit()
	check_eq(got.size(), 2, "Anzahl der empfangenen Signale")
	check_eq(got[0], Diet.FLEISCHFRESSER, "Erster Wert ist Fleischfresser")
	check_eq(got[1], Diet.PFLANZENFRESSER, "Zweiter Wert ist Pflanzenfresser")


func test_fortsetzen() -> void:
	check(menu.continue_button.disabled, "Fortsetzen-Button zuerst deaktiviert")
	menu.set_can_continue(true)
	check(not menu.continue_button.disabled, "Fortsetzen-Button nach set_can_continue aktiviert")
	menu.continue_game.connect(func() -> void: got.append(1))
	menu.continue_button.pressed.emit()
	check_eq(got.size(), 1, "Signal continue_game wurde gesendet")


func test_beenden_und_einstellungen() -> void:
	got.clear()
	menu.quit_game.connect(func() -> void: got.append("quit"))
	menu.open_settings.connect(func() -> void: got.append("settings"))
	menu.quit_button.pressed.emit()
	menu.settings_button.pressed.emit()
	check_eq(got.size(), 2, "Beide Signale wurden gesendet")
