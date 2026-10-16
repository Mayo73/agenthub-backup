extends "res://tests/base_test.gd"

var menu: PauseMenu
var got: Array = []


func setup() -> void:
	menu = PauseMenu.new()


func teardown() -> void:
	menu.free()


func test_start_verborgen() -> void:
	check(menu.visible == false, "menu.visible sollte falsch sein")
	check(menu.process_mode == Node.PROCESS_MODE_ALWAYS, "process_mode sollte PROCESS_MODE_ALWAYS sein")
	check(menu.box.get_child_count() == 5, "box sollte 5 Kinder haben")


func test_oeffnen_schliessen() -> void:
	menu.open()
	check(menu.visible == true, "menu.visible sollte nach open() wahr sein")
	menu.close()
	check(menu.visible == false, "menu.visible sollte nach close() falsch sein")


func test_signale() -> void:
	menu.resume.connect(func() -> void: got.append("resume"))
	menu.open_settings.connect(func() -> void: got.append("open_settings"))
	menu.to_main_menu.connect(func() -> void: got.append("to_main_menu"))
	menu.quit_game.connect(func() -> void: got.append("quit_game"))
	menu.resume_button.pressed.emit()
	menu.settings_button.pressed.emit()
	menu.main_menu_button.pressed.emit()
	menu.quit_button.pressed.emit()
	check(got.size() == 4, "alle vier Signale sollten empfangen worden sein")


func test_texte() -> void:
	check(menu.resume_button.text == "Weiter", "resume_button sollte 'Weiter' zeigen")
	check(menu.main_menu_button.text == "Hauptmenü", "main_menu_button sollte 'Hauptmenü' zeigen")
