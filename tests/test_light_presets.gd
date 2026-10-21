extends "res://tests/base_test.gd"

var light: LightPresets


func setup() -> void:
	light = LightPresets.new()


func test_namen() -> void:
	var namen: Array[String] = light.names()
	check_eq(namen.size(), 3, "names() hat 3 Einträge")
	check_eq(namen[0], "abend", "names()[0] == \"abend\"")
	check_eq(namen[1], "innen", "names()[1] == \"innen\"")
	check_eq(namen[2], "mittag", "names()[2] == \"mittag\"")


func test_gueltig() -> void:
	for name in light.names():
		var preset := light.get_preset(name)
		var errors := light.validate(preset)
		check(errors.is_empty(), "validate(%s) ergibt leere Liste" % name)


func test_fehler() -> void:
	var ungultiges := {"kind": "laser", "energy": 20.0, "rotation": [0, 0], "range": 0.0, "shadows": false}
	var errors := light.validate(ungultiges)
	check(errors.size() >= 3, "validate mit falschem Licht hat mindestens 3 Meldungen")


func test_kopie() -> void:
	var erste := light.get_preset("mittag")
	erste["energy"] = 999.0
	var zweite := light.get_preset("mittag")
	check_eq(zweite["energy"], 1.2, "Änderung an get_preset ändert neue Kopie nicht")


func test_abstand() -> void:
	var innen := light.get_preset("innen")
	var energie_4 := light.energy_at(innen, 4.0)
	check(energie_4 >= 0.45 and energie_4 <= 0.55, "energy_at(innen, 4.0) ist ungefähr 0.5")

	var energie_10 := light.energy_at(innen, 10.0)
	check_eq(energie_10, 0.0, "energy_at(innen, 10.0) ist 0.0")

	var mittag := light.get_preset("mittag")
	var energie_sonne := light.energy_at(mittag, 100.0)
	check_eq(energie_sonne, 1.2, "energy_at(mittag, 100.0) ist 1.2")
