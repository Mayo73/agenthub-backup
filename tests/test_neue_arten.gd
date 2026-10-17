extends "res://tests/base_test.gd"

func test_abschnitte() -> void:
	check(SpeciesCatalog.ids_near_stage(0).has("flimmerling"), "flimmerling in Abschnitt 0")
	check(SpeciesCatalog.ids_near_stage(3).has("panzerling"), "panzerling in Abschnitt 3")
	check(SpeciesCatalog.ids_near_stage(4).has("schwebqualle"), "schwebqualle in Abschnitt 4")
	check(not SpeciesCatalog.ids_near_stage(2).has("schwebqualle"), "schwebqualle nicht in Abschnitt 2")


func test_flimmerling_flieht() -> void:
	check(AiBrain.is_threat(SpeciesCatalog.radius_of("flimmerling"), CellProgress.radius_for_stage(1), Diet.FLEISCHFRESSER), "Flimmerling flieht vor Fleischfresser in Abschnitt 1")
	check(not AiBrain.is_threat(SpeciesCatalog.radius_of("flimmerling"), CellProgress.radius_for_stage(0), Diet.FLEISCHFRESSER), "Flimmerling flieht nicht vor Fleischfresser in Abschnitt 0")


func test_ki_zelle() -> void:
	var c := AiCell.new()
	c.setup("panzerling", Vector2(5, 5))
	check_eq(c.radius, 27.0, "Panzerling-Radius")
	check_eq(c.damage, 0.0, "Panzerling-Damage")
	check_eq(c.diet, Diet.PFLANZENFRESSER, "Panzerling-Diaet")
	check_eq(c.motion.max_speed, 70.0, "Panzerling-Geschwindigkeit")
	check_eq(c.behavior, "scheu", "Panzerling-Verhalten")
	c.free()


func test_panzerling_stacheln() -> void:
	var t := SpeciesWeapons.spike_tips("panzerling", Vector2.ZERO, 0.0, 27.0)
	check_eq(t.size(), 2, "Anzahl der Stachelspitzen")
	check(t[0].x < 0.0, "Stachel links vom Zentrum")
	check(t[1].x < 0.0, "Stachel links vom Zentrum")


func test_spawner() -> void:
	var s := EcoSpawner.new(3)
	var flimmerling_gefunden := false
	var schwebqualle_gefunden := false
	for _i in range(300):
		var id := s.pick_species(0)
		if id == "flimmerling":
			flimmerling_gefunden = true
	check(flimmerling_gefunden, "Flimmerling beim Spawning in Abschnitt 0")

	s = EcoSpawner.new(3)
	for _i in range(300):
		var id := s.pick_species(4)
		if id == "schwebqualle":
			schwebqualle_gefunden = true
		if id == "flimmerling":
			check(false, "Flimmerling darf nicht bei Abschnitt 4 erscheinen")
	check(schwebqualle_gefunden, "Schwebqualle beim Spawning in Abschnitt 4")
