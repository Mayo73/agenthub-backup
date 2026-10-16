extends "res://tests/base_test.gd"

var look: CellLook


func setup() -> void:
	pass


func teardown() -> void:
	pass


func test_schnapper() -> void:
	look = SpeciesCatalog.look_of("schnapper")
	check(look.pattern == "streifen", "pattern von schnapper ist 'streifen'")
	check_eq(look.stretch, 1.3, "stretch von schnapper ist 1.3")
	var expected_color: Color = SpeciesCatalog.data("schnapper")["color"]
	check(look.color.is_equal_approx(expected_color), "color von schnapper stimmt")


func test_unbekannt() -> void:
	look = SpeciesCatalog.look_of("gibtsnicht")
	check(look.pattern == "keins", "pattern bei unbekannter ID ist 'keins'")
	check_eq(look.stretch, 1.0, "stretch bei unbekannter ID ist 1.0")


func test_alle_gueltig() -> void:
	for id in SpeciesCatalog.ids():
		var pattern: String = SpeciesCatalog.data(id)["pattern"]
		check(CellLook.PATTERNS.has(pattern), "pattern '%s' für %s ist gültig" % [pattern, id])
		var stretch_from_look := SpeciesCatalog.look_of(id).stretch
		var stretch_from_data := float(SpeciesCatalog.data(id)["stretch"])
		check_eq(stretch_from_look, stretch_from_data, "stretch für %s stimmt" % id)


func test_verschieden() -> void:
	var combinations := {}
	for id in SpeciesCatalog.ids():
		var data := SpeciesCatalog.data(id)
		var key := str(data["pattern"]) + str(data["stretch"])
		combinations[key] = true
	check(combinations.size() >= 7, "mindestens 7 verschiedene Kombinationen von Muster und Streckung")
