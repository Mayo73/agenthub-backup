extends "res://tests/base_test.gd"

const P := "user://test_platz_"


func teardown() -> void:
	for slot in range(1, 4):
		var path := SaveSlots.path_for(slot, P)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func test_pfade() -> void:
	check_eq(SaveSlots.path_for(2), "user://spielstand_2.json", "Default-Pfad für slot 2")
	check_eq(SaveSlots.path_for(9, P), "user://test_platz_3.json", "Slot 9 mit eigenem Prefix wird auf 3 begrenzt")
	check_eq(SaveSlots.path_for(0, P), "user://test_platz_1.json", "Slot 0 mit eigenem Prefix wird auf 1 begrenzt")


func test_leer() -> void:
	check_eq(SaveSlots.summary(SaveSlots.path_for(1, P)), "Leer", "Zusammenfassung eines leeren Platzes")
	check_eq(SaveSlots.first_used(P), 0, "Kein belegter Platz")


func test_beschreibung() -> void:
	SaveGame.write_file(SaveSlots.path_for(2, P), {"stage": 2, "dna": 42, "diet": Diet.PFLANZENFRESSER})
	check_eq(SaveSlots.summary(SaveSlots.path_for(2, P)), "Größe 3 · 42 DNA · Pflanzenfresser", "Zusammenfassung mit Werten")
	check_eq(SaveSlots.first_used(P), 2, "Erster belegter Platz ist 2")
