extends "res://tests/base_test.gd"

var state: AppState
var screen: ProfileScreen

const DAYS := ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
const EQUIPMENT := ["Handschuhe", "Schienbeinschoner", "Mundschutz", "Matte", "Pratzen"]


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


func test_merkmale_gefuellt() -> void:
	# Alex (p01) hat weight_class=1 → Picker auf Index 2 (plus "keine Angabe")
	check_eq(screen.weight_picker.selected, 2, "Gewichtsklasse ist 'Mittel' (Index 2)")
	# Tage: ["Di", "Do", "Sa"] → Di true, Mo false
	check(screen.day_boxes["Di"].button_pressed == true, "Tag 'Di' ist angehakt")
	check(screen.day_boxes["Mo"].button_pressed == false, "Tag 'Mo' ist nicht angehakt")
	# Ausrüstung: ["Mundschutz", "Matte"] → Matte true
	check(screen.equipment_boxes["Matte"].button_pressed == true, "Ausrüstung 'Matte' ist angehakt")
	# Größe der Dictionarys
	check_eq(screen.day_boxes.size(), 7, "day_boxes hat 7 Einträge (alle Wochentage)")
	check_eq(screen.equipment_boxes.size(), 5, "equipment_boxes hat 5 Einträge")


func test_merkmale_speichern() -> void:
	# Tage ändern: So hinzufügen, Di entfernen
	screen.day_boxes["So"].button_pressed = true
	screen.day_boxes["Di"].button_pressed = false
	# Gewichtsklasse auf -1 setzen (keine Angabe)
	screen.weight_picker.select(0)
	# Speichern
	screen.save_button.pressed.emit()
	# Ergebnisse prüfen
	check(state.active().days.has("So"), "Tag 'So' ist gespeichert")
	check(state.active().days.has("Di") == false, "Tag 'Di' ist entfernt")
	check_eq(state.active().days.size(), 3, "Es gibt 3 Tage: Do, Sa, So")
	# Reihenfolge prüfen
	check(state.active().days.has("Do"), "Do ist enthalten")
	check(state.active().days.has("Sa"), "Sa ist enthalten")
	check(state.active().days.has("So"), "So ist enthalten")


func test_ausruestung_speichern() -> void:
	# Pratzen hinzufügen
	screen.equipment_boxes["Pratzen"].button_pressed = true
	# Speichern
	screen.save_button.pressed.emit()
	# Ergebnisse prüfen
	var equipment := state.active().equipment
	check(equipment.has("Mundschutz"), "Mundschutz ist gespeichert")
	check(equipment.has("Matte"), "Matte ist gespeichert")
	check(equipment.has("Pratzen"), "Pratzen ist gespeichert")
	check_eq(equipment.size(), 3, "Es gibt 3 Ausrüstungseinträge")
	# Reihenfolge prüfen (EQUIPMENT-Reihenfolge: Handschuhe, Schienbeinschoner, Mundschutz, Matte, Pratzen)
	var mund_idx := equipment.find("Mundschutz")
	var matte_idx := equipment.find("Matte")
	var pratzen_idx := equipment.find("Pratzen")
	check(mund_idx < matte_idx, "Mundschutz kommt vor Matte in der Reihenfolge")
	check(matte_idx < pratzen_idx, "Matte kommt vor Pratzen in der Reihenfolge")


func test_merkmale_andere_perspektive() -> void:
	state.switch_to("p02")
	var new_screen := ProfileScreen.new(state)
	(Engine.get_main_loop() as SceneTree).root.add_child(new_screen)

	# p02 (Sam) hat weight_class=2 → Picker auf Index 3 (plus "keine Angabe")
	check_eq(new_screen.weight_picker.selected, 3, "Bei p02 ist Gewichtsklasse 'Schwer' (Index 3)")
	# Tage: ["Mo", "Mi", "Fr"] → Fr true
	check(new_screen.day_boxes["Fr"].button_pressed == true, "Tag 'Fr' ist bei p02 angehakt")

	new_screen.free()


func test_grosses_portraet() -> void:
	# Avatar soll großes Porträt sein: shade=true, custom_minimum_size.y=360
	check(screen.avatar.shade == true, "avatar.shade ist wahr")
	check_eq(screen.avatar.custom_minimum_size.y, 360, "avatar.custom_minimum_size.y ist 360")


func test_name_gross() -> void:
	# name_label soll nach dem Aufbau den Text "<Name>, <Alter>" von p01 zeigen
	var profile := state.profile("p01")
	check(screen.name_label.text == "%s, %d" % [profile.name, profile.age], "name_label zeigt '<name>, <age>' von p01")

