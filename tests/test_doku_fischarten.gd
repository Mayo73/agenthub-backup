extends "res://tests/base_test.gd"

const PATH := "res://docs/fischarten.md"


func test_datei() -> void:
	check(FileAccess.file_exists(PATH), "Datei existiert")
	var file := FileAccess.open(PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	check(text.begins_with("# Fischarten der Fischphase"),
		"Text beginnt mit '# Fischarten der Fischphase'")


func test_alle_arten() -> void:
	var file := FileAccess.open(PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	for id in FishSpecies.ids():
		var name: String = FishSpecies.data(id)["name"]
		check(text.contains("## " + name),
			"Text enthält '## " + name + "' für Fischart " + str(id))


func test_tipps() -> void:
	var file := FileAccess.open(PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	check(text.contains("## Tipps"),
		"Text enthält '# Tipps'")
	var zackenbarsch_pos := text.find("## Zackenbarsch")
	var tipps_pos := text.find("## Tipps")
	check(tipps_pos > zackenbarsch_pos,
		"'## Tipps' steht nach '## Zackenbarsch'")
