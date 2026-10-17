extends "res://tests/base_test.gd"


func test_arten() -> void:
	check_eq(FishSpecies.ids(), ["grasfisch", "silberling", "zackenbarsch"], "alle Arten sortiert")
	check(FishSpecies.has("silberling"), "silberling existiert")
	check(not FishSpecies.has("hai"), "hai existiert nicht")


func test_werte() -> void:
	check_eq(FishSpecies.data("zackenbarsch")["bite"], 15.0, "Bissschaden Zackenbarsch")
	check_eq(FishSpecies.data("hai"), {}, "unbekannte Art liefert leeres Dictionary")


func test_radius() -> void:
	var radius_silberling := FishSpecies.radius("silberling")
	var radius_zackenbarsch := FishSpecies.radius("zackenbarsch")
	check(is_equal_approx(radius_silberling, 0.3), "Radius Silberling 0.3")
	check(is_equal_approx(radius_zackenbarsch, 0.9), "%s != 0.9" % radius_zackenbarsch)


func test_raeuber() -> void:
	check(FishSpecies.is_predator("zackenbarsch"), "Zackenbarsch ist Räuber")
	check(not FishSpecies.is_predator("silberling"), "Silberling kein Räuber")
	check(not FishSpecies.is_predator("hai"), "Hai kein Räuber (unbekannt)")


func test_vollstaendig() -> void:
	var required_keys := ["name", "size", "speed", "hp", "bite", "behavior", "color", "food", "sight"]
	for id: String in FishSpecies.ids():
		var d := FishSpecies.data(id)
		for key: String in required_keys:
			check(d.has(key), "Art %s hat Schlüssel %s" % [id, key])
