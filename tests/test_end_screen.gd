extends "res://tests/base_test.gd"

var screen: EndScreen


func setup() -> void:
	screen = EndScreen.new()


func teardown() -> void:
	screen.free()


func test_verborgen() -> void:
	check(not screen.visible, "screen.visible soll falsch sein")
	check(screen.process_mode == Node.PROCESS_MODE_ALWAYS, "process_mode soll PROCESS_MODE_ALWAYS sein")


func test_rueckblick() -> void:
	var s := RunStats.new()
	s.food_eaten = 5
	s.record_stage(Diet.FLEISCHFRESSER)
	screen.show_stats(s)
	check(screen.visible, "screen.visible soll wahr sein nach show_stats()")
	check(screen.lines_box.get_child_count() == 6, "lines_box soll 6 Kinder haben")
	var child1 := screen.lines_box.get_child(1) as Label
	check(child1.text == "Nahrung gefressen: 5", "Kind 1 soll 'Nahrung gefressen: 5' sein")
	var child5 := screen.lines_box.get_child(5) as Label
	check(child5.text == "Hauptnahrung: Fleischfresser", "Kind 5 soll 'Hauptnahrung: Fleischfresser' sein")


func test_zweimal() -> void:
	screen.show_stats(RunStats.new())
	screen.show_stats(RunStats.new())
	check(screen.lines_box.get_child_count() == 6, "lines_box soll 6 Kinder haben nach zweimaligem Aufruf")
	var child5 := screen.lines_box.get_child(5) as Label
	check(child5.text == "Hauptnahrung: unbekannt", "Kind 5 soll 'Hauptnahrung: unbekannt' sein")


func test_namen() -> void:
	check(EndScreen.diet_name(Diet.PFLANZENFRESSER) == "Pflanzenfresser", "PFLANZENFRESSER soll 'Pflanzenfresser' ergeben")
	check(EndScreen.diet_name(Diet.ALLESFRESSER) == "Allesfresser", "ALLESFRESSER soll 'Allesfresser' ergeben")
	check(EndScreen.diet_name("") == "unbekannt", "leerer String soll 'unbekannt' ergeben")


func test_signale() -> void:
	var got: Array = []
	screen.to_main_menu.connect(func() -> void: got.append("main"))
	screen.quit_game.connect(func() -> void: got.append("quit"))
	screen.menu_button.pressed.emit()
	screen.quit_button.pressed.emit()
	check(got.size() == 2, "soll zwei Signale empfangen haben")
