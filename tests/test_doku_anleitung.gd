extends "res://tests/base_test.gd"

const PATH := "res://docs/ANLEITUNG.md"


func test_datei() -> void:
	check(FileAccess.file_exists(PATH), "Datei existiert")
	var text := FileAccess.get_file_as_string(PATH)
	check(text.begins_with("# Zellenphase – Bedienungsanleitung"), "Startet mit korrektem Titel")


func test_abschnitte() -> void:
	var text := FileAccess.get_file_as_string(PATH)
	for eintrag in ["## Spielstart", "## Steuerung", "## Ziel", "## Nahrung und Mundwerkzeuge", "## Zelleditor", "## Spielstände und Einstellungen", "## Leistungstest und Vorführszenen"]:
		check(text.contains(eintrag), "Enthält Abschnitt: %s" % eintrag)


func test_tasten() -> void:
	var text := FileAccess.get_file_as_string(PATH)
	for eintrag in ["WASD", "Esc", "rechte Maustaste", "Filtermaul", "Kiefer", "Rüssel", "--benchmark"]:
		check(text.contains(eintrag), "Enthält: %s" % eintrag)


func test_szenen() -> void:
	var text := FileAccess.get_file_as_string(PATH)
	for n in DemoScenes.names():
		check(text.contains(n), "Enthält Szenennamen: %s" % n)
