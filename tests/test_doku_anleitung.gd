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


func test_fischphase_beschrieben() -> void:
	var text := FileAccess.get_file_as_string(PATH)
	check(text.contains("## Fischphase"), "Enthält Abschnitt Fischphase")
	check(text.contains("Entwicklungsmenü"), "Enthält Entwicklungsmenü")
	check(text.contains("-- --fisch"), "Enthält Start-Parameter -- --fisch")
	check(text.find("## Fischphase") < text.find("## Leistungstest und Vorführszenen"), "Abschnitt Fischphase steht vor Leistungstest")


func test_fischphase_fortsetzen() -> void:
	var text := FileAccess.get_file_as_string(PATH)
	var fisch_start := text.find("## Fischphase")
	var leistung_start := text.find("## Leistungstest und Vorführszenen")
	check(fisch_start >= 0, "Abschnitt Fischphase gefunden")
	check(leistung_start > fisch_start, "Abschnitt Leistungstest nach Fischphase")
	var fischphase := text.substr(fisch_start, leistung_start - fisch_start)
	check(fischphase.contains("Pausemenü"), "Fischphase enthält 'Pausemenü'")
	check(fischphase.contains("Fortsetzen"), "Fischphase enthält 'Fortsetzen'")
	check(fischphase.contains("E: Verbesserung möglich"), "Fischphase enthält 'E: Verbesserung möglich'")
