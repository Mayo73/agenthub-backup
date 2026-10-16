extends "res://tests/base_test.gd"
## Tests für SpeciesParts.

func setup() -> void:
	pass


func teardown() -> void:
	pass


func test_alle_arten() -> void:
	## Jedes Teil der Teile-Map muss im PartCatalog existieren.
	for id: String in SpeciesCatalog.ids():
		var parts: Array = SpeciesParts.parts_of(id)
		check(parts.size() >= 1, "Art %s hat keine Teile" % [id])
		for part: Dictionary in parts:
			var part_id := part["id"] as String
			check(PartCatalog.exists(part_id), "Teil %s der Art %s existiert nicht im PartCatalog" % [part_id, id])


func test_maul_passt() -> void:
	## Für jede Art genau ein Maul-Typ: filtermaul bei Pflanzenfresser, kiefer bei Fleischfressern, ruessel bei Allesfressern.
	for id: String in SpeciesCatalog.ids():
		var parts: Array = SpeciesParts.parts_of(id)
		var maul_parts: Array = []
		for part: Dictionary in parts:
			if PartCatalog.category_of(part["id"] as String) == "maul":
				maul_parts.append(part)
		check(maul_parts.size() == 1, "Art %s hat %d Mäuler statt genau einem" % [id, maul_parts.size()])

		var expected_mouth: String = ""
		if SpeciesCatalog.data(id)["diet"] == Diet.PFLANZENFRESSER:
			expected_mouth = "filtermaul"
		elif SpeciesCatalog.data(id)["diet"] == Diet.FLEISCHFRESSER:
			expected_mouth = "kiefer"
		elif SpeciesCatalog.data(id)["diet"] == Diet.ALLESFRESSER:
			expected_mouth = "ruessel"

		check(maul_parts[0]["id"] == expected_mouth, "Art %s hat Maul %s statt erwartetem %s" % [id, maul_parts[0]["id"], expected_mouth])


func test_unbekannt() -> void:
	var unknown_parts := SpeciesParts.parts_of("gibtsnicht")
	check(unknown_parts.size() == 0, "Unbekannte ID sollte leere Array zurückgeben, bekommen %d" % [unknown_parts.size()])

	var unknown_stretched := SpeciesParts.placed_parts("gibtsnicht", 1.0)
	check(unknown_stretched.size() == 0, "Unbekannte ID mit Streckung sollte leere Array zurückgeben, bekommen %d" % [unknown_stretched.size()])


func test_gestreckt() -> void:
	## Kiefer von schnapper bei stretch=1.3 muss bei (1.3, 0) liegen
	var p := SpeciesParts.placed_parts("schnapper", 1.3)
	check((p[0]["pos"] as Vector2).is_equal_approx(Vector2(1.3, 0)), "Kiefer von Schnapper sollte bei stretch=1.3 nach (1.3, 0) verschoben sein")

	## Zweites Wimpern von weidezelle: y-Position wird durch 1.25 geteilt
	var w := SpeciesParts.placed_parts("weidezelle", 1.25)
	check(w[1]["pos"].is_equal_approx(Vector2(0, 0.8)), "Wimper oben von Weidezelle sollte bei stretch=1.25 nach (0, 0.8) verschoben sein")


func test_original_bleibt() -> void:
	var original := SpeciesParts.parts_of("schnapper")
	check((original[0]["pos"] as Vector2).is_equal_approx(Vector2(1, 0)), "Original sollte unverändert bei (1, 0) bleiben")

	## placed_parts aufrufen – darf parts_of() nicht verändern
	SpeciesParts.placed_parts("schnapper", 2.0)
	check((SpeciesParts.parts_of("schnapper")[0]["pos"] as Vector2).is_equal_approx(Vector2(1, 0)), "Original muss auch nach placed_parts() bei (1, 0) bleiben")
