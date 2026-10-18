extends "res://tests/base_test.gd"

func test_anleitung_vorhanden() -> void:
	var file := FileAccess.get_file_as_string("res://docs/ANLEITUNG.md")
	check(file != null and file.length() > 0, "Datei existiert und ist nicht leer")
	check(file.find("# Sparring – Anleitung") == 0, "Beginnt mit korrekter Überschrift")

func test_abschnitte() -> void:
	var file := FileAccess.get_file_as_string("res://docs/ANLEITUNG.md")
	check(file != null, "Datei existiert")

	check("## Testperson wechseln" in file, "enthält '## Testperson wechseln'")
	check("## Kompletter Testablauf" in file, "enthält '## Kompletter Testablauf'")
	check("## Zurücksetzen" in file, "enthält '## Zurücksetzen'")
	check("## Freiwilligkeit" in file, "enthält '## Freiwilligkeit'")
	check("## Installation" in file, "enthält '## Installation'")

	var pos_wechsel := file.find("## Testperson wechseln")
	var pos_ablauf := file.find("## Kompletter Testablauf")
	var pos_zurueck := file.find("## Zurücksetzen")

	check(pos_wechsel >= 0 and pos_ablauf > pos_wechsel, "'## Testperson wechseln' steht vor '## Kompletter Testablauf'")
	check(pos_ablauf >= 0 and pos_zurueck > pos_ablauf, "'## Kompletter Testablauf' steht vor '## Zurücksetzen'")

func test_inhalt() -> void:
	var file := FileAccess.get_file_as_string("res://docs/ANLEITUNG.md")
	check(file != null, "Datei existiert")

	check("Demo zurücksetzen" in file, "enthält 'Demo zurücksetzen'")
	check("Du bist:" in file, "enthält 'Du bist:'")
	check("keine Anmeldung" in file, "enthält 'keine Anmeldung'")
	check("zustimmen" in file, "enthält 'zustimmen'")
