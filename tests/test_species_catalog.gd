extends "res://tests/base_test.gd"


func test_acht_arten() -> void:
	var ids := SpeciesCatalog.ids()
	check_eq(ids.size(), 11, "elf Arten")
	var names: Array[String] = []
	for id in ids:
		var n := SpeciesCatalog.name_of(id)
		check(n != "", "Name von %s nicht leer" % id)
		check(not names.has(n), "Name %s nur einmal" % n)
		names.append(n)


func test_ernaehrung_gueltig() -> void:
	for id in SpeciesCatalog.ids():
		var diet: String = SpeciesCatalog.data(id)["diet"]
		check(diet in [Diet.PFLANZENFRESSER, Diet.FLEISCHFRESSER, Diet.ALLESFRESSER], "Ernährung von %s gültig" % id)


func test_radius() -> void:
	check_eq(SpeciesCatalog.radius_of("riesenschlund"), 60.0, "Riesenschlund 60")
	check_eq(SpeciesCatalog.radius_of("schnapper"), 18.0, "Schnapper 18")
	check_eq(SpeciesCatalog.radius_of("gibtsnicht"), 0.0, "unbekannt 0")
	check(SpeciesCatalog.data("gibtsnicht").is_empty(), "unbekannt leer")


func test_jeder_abschnitt() -> void:
	for s in 5:
		var found := false
		for id in SpeciesCatalog.ids():
			if SpeciesCatalog.data(id)["stage"] == s:
				found = true
		check(found, "Abschnitt %d hat eine Art" % s)


func test_nahe_abschnitte() -> void:
	var near0: Array[String] = ["blasenling", "flimmerling", "schnapper", "stachelkugel"]
	var near4: Array[String] = ["weidezelle", "hornjaeger", "riesenschlund", "schwebqualle"]
	check_eq(SpeciesCatalog.ids_near_stage(0), near0, "nahe Abschnitt 0")
	check_eq(SpeciesCatalog.ids_near_stage(4), near4, "nahe Abschnitt 4")


func test_neue_arten() -> void:
	check_eq(SpeciesCatalog.radius_of("flimmerling"), 12.0, "Flimmerling radius")
	check_eq(SpeciesCatalog.radius_of("panzerling"), 27.0, "Panzerling radius")
	check_eq(SpeciesCatalog.radius_of("schwebqualle"), 60.0, "Schwebqualle radius")
	check_eq(SpeciesCatalog.data("schwebqualle")["damage"], 0.0, "Schwebqualle damage")
	check_eq(PartDrops.DROPS["panzerling"], "stachel", "Panzerling Drop")
	check_eq(SpeciesParts.parts_of("schwebqualle").size(), 4, "Schwebqualle Teile")
