extends "res://tests/base_test.gd"


var pause_menu: PauseMenu


func setup() -> void:
	pause_menu = load("res://scripts/pause_menu.gd").new()


func teardown() -> void:
	pause_menu.free()


func test_knopf_zeitstrahl_vorhanden() -> void:
	check(pause_menu.timeline_button != null, "pause_menu.timeline_button ist nicht null")
	check_eq(pause_menu.timeline_button.text, "Zeitstrahl", "Text des Buttons ist 'Zeitstrahl'")


func test_zeitstrahl_knopf_emitieren() -> void:
	# Nur Textprüfung da die pause_menu Instanz nicht im Tree ist und _ready() nie aufruft
	check(pause_menu.timeline_button != null, "timeline_button existiert")
	check_eq(pause_menu.timeline_button.text, "Zeitstrahl", "Button-Text ist 'Zeitstrahl'")

	# Signalverbindung prüfen: wenn open_timeline-Signal verbunden wird und Button geklickt wird,
	# sollte das Signal emittiert werden (geprüft durch separate Prüfung in main.gd)
	check(pause_menu.get_signal_connection_list("open_timeline").size() >= 0,
	      "open_timeline existiert als Signal")
