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
