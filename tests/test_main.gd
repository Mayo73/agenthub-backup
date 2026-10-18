extends "res://tests/base_test.gd"

var main: Main


func setup() -> void:
	main = (load("res://scenes/main.tscn") as PackedScene).instantiate() as Main
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()


func test_prototyp_hinweis() -> void:
	check(main.banner.text.contains("PROTOTYP"), "Kopfzeile kennzeichnet den Prototyp")
	check(main.banner.text.contains("Testprofile"), "Kopfzeile nennt die Testprofile")


func test_startet_mit_entdecken() -> void:
	check_eq(main.current_screen, "entdecken", "erster Bildschirm")
	check_eq(main.tab_buttons.size(), 3, "Reiter")
	check(main.tab_buttons["entdecken"].disabled, "aktiver Reiter ist gesperrt")


func test_reiter_wechselt_bildschirm() -> void:
	main.tab_buttons["profil"].pressed.emit()
	check_eq(main.current_screen, "profil", "nach Klick auf Profil")
	check_eq(main.content.get_child_count(), 1, "genau ein Bildschirm im Inhaltsbereich")
	check(not main.tab_buttons["entdecken"].disabled, "Entdecken wieder klickbar")


const TEST_PATH := "user://test_main.json"


func test_entdecken_ist_echt() -> void:
	main.use_store(TEST_PATH)
	check(main.screen is DiscoverScreen, "Entdecken zeigt den echten Bildschirm")
	DirAccess.remove_absolute(TEST_PATH)


func test_wechsel_speichert() -> void:
	main.use_store(TEST_PATH)
	main._on_switched("p02")
	check_eq(main.state.active_id, "p02", "aktive Person")
	check_eq(StateStore.load_state(TEST_PATH).active_id, "p02", "gespeicherte aktive Person")
	check(main.screen is DiscoverScreen, "Entdecken nach dem Wechsel")
	DirAccess.remove_absolute(TEST_PATH)


func test_interesse_wird_gespeichert() -> void:
	main.use_store(TEST_PATH)
	(main.screen as DiscoverScreen).like_button.pressed.emit()
	check(StateStore.load_state(TEST_PATH).book.likes.has("p01>p02"), "Interesse gespeichert")
	DirAccess.remove_absolute(TEST_PATH)


func test_profil_ist_echt() -> void:
	main.use_store(TEST_PATH)
	main.show_screen("profil")
	check(main.screen is ProfileScreen, "Profil ist der echte Bildschirm")
	DirAccess.remove_absolute(TEST_PATH)


func test_profil_wird_gespeichert() -> void:
	main.use_store(TEST_PATH)
	main.show_screen("profil")
	var ps = main.screen as ProfileScreen
	ps.name_edit.text = "Alexa"
	ps.save_button.pressed.emit()

	var loaded = StateStore.load_state(TEST_PATH)
	check_eq(loaded.profile("p01").name, "Alexa", "Name im Load")
	main.perspective.set_state(loaded)
	check(main.perspective.picker.get_item_text(0).begins_with("Du bist: Alexa"), "Perspektive zeigt neuen Namen")
	DirAccess.remove_absolute(TEST_PATH)


func test_zuruecksetzen() -> void:
	main.use_store(TEST_PATH)
	main.state.like("p01>p02")
	main.save()
	check(not main.state.book.likes.is_empty(), "Likes vor dem Zurücksetzen")

	main.show_screen("profil")
	var ps = main.screen as ProfileScreen
	ps.reset_button.pressed.emit()
	ps.dialog.ok_button.pressed.emit()

	check(main.state.book.likes.is_empty(), "Nach Reset sind Likes leer")
	check_eq(main.current_screen, "entdecken", "Zurücksetzen zeigt Entdecken")
	check(StateStore.load_state(TEST_PATH).book.likes.is_empty(), "Gespeicherte Datei hat keine Likes")
	DirAccess.remove_absolute(TEST_PATH)
