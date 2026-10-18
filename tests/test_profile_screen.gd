extends "res://tests/base_test.gd"

var state: AppState
var screen: ProfileScreen


func setup() -> void:
	state = AppState.demo()
	screen = ProfileScreen.new(state)
	(Engine.get_main_loop() as SceneTree).root.add_child(screen)


func teardown() -> void:
	screen.free()


func test_felder_gefuellt() -> void:
	check(screen.name_edit.text == "Alex", "Name ist Alex")
	check(screen.art_picker.get_item_text(screen.art_picker.selected) == "Jiu-Jitsu", "Kampfsportart ist Jiu-Jitsu")
	check_eq(screen.level_picker.selected, 1, "Erfahrung ist Fortgeschritten (Index 1)")
	check_eq(int(screen.age_spin.value), 29, "Alter ist 29")


func test_speichern() -> void:
	var initial_name = state.active().name
	screen.name_edit.text = "Alexa"
	screen.save_button.pressed.emit()
	check(state.active().name == "Alexa", "Name wurde aktualisiert auf Alexa")
	check(screen.error_label.text == "Gespeichert.", "Error-Label zeigt 'Gespeichert.'")


func test_fehler_anzeigen() -> void:
	var initial_name = state.active().name
	screen.name_edit.text = ""
	var result := screen.save_profile()
	check(result == false, "save_profile gibt false bei Fehlern zurück")
	check("Name fehlt" in screen.error_label.text, "Error-Label enthält 'Name fehlt'")
	check(state.active().name == initial_name, "Name bleibt unverändert")


func test_andere_perspektive() -> void:
	state.switch_to("p02")
	var new_screen := ProfileScreen.new(state)
	(Engine.get_main_loop() as SceneTree).root.add_child(new_screen)

	check(new_screen.name_edit.text == "Sam", "Bei p02 ist Name 'Sam'")

	new_screen.free()


func test_zuruecksetzen_fragt() -> void:
	screen.reset_button.pressed.emit()
	check(screen.dialog.visible == true, "Dialog ist nach Klick sichtbar")


func test_zuruecksetzen_abbrechen() -> void:
	screen.reset_button.pressed.emit()
	screen.dialog.cancel_button.pressed.emit()

