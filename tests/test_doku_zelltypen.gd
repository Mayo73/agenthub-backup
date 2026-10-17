extends "res://tests/base_test.gd"

const PATH := "res://docs/zelltypen.md"


func test_datei() -> void:
	check(FileAccess.file_exists(PATH), "Dokumentationsdatei existiert")
	var text := FileAccess.get_file_as_string(PATH)
	check(text.begins_with("# Zelltypen der Zellenphase"), "Datei beginnt mit korrekter Überschrift")


func test_alle_arten() -> void:
	var text := FileAccess.get_file_as_string(PATH)
	for id in SpeciesCatalog.ids():
		check(text.contains("## " + SpeciesCatalog.name_of(id)), "Dokumentation für " + SpeciesCatalog.name_of(id) + " vorhanden")


func test_vorfuehrung() -> void:
	var text := FileAccess.get_file_as_string(PATH)
	check(text.contains("## Vorführung"), "Abschnitt 'Vorführung' vorhanden")
	check(text.contains("--szene=jagd"), "Startbefehl für Szene 'jagd' dokumentiert")
	check(text.contains("--szene=flucht"), "Startbefehl für Szene 'flucht' dokumentiert")
	check(text.contains("--szene=nahrung"), "Startbefehl für Szene 'nahrung' dokumentiert")
