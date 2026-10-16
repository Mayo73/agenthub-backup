extends "res://tests/base_test.gd"

func test_acht_szenen() -> void:
	check_eq(DemoScenes.names().size(), 8, "genau 8 Szenen")
	check(DemoScenes.exists("gift"), "gift existiert")
	check(not DemoScenes.exists("quatsch"), "quatsch existiert nicht")


func test_vollstaendig() -> void:
	var namen := DemoScenes.names()
	for n in namen:
		var d := DemoScenes.data(n)
		check(d.has("text"), "szene '" + n + "' hat 'text'")
		check(d.has("stage"), "szene '" + n + "' hat 'stage'")
		check(d.has("diet"), "szene '" + n + "' hat 'diet'")
		check(d.has("parts"), "szene '" + n + "' hat 'parts'")
		check(d.has("ai"), "szene '" + n + "' hat 'ai'")
		check(d.has("food"), "szene '" + n + "' hat 'food'")


func test_gueltige_ids() -> void:
	var namen := DemoScenes.names()
	for n in namen:
		var d := DemoScenes.data(n)
		for ai_entry: Array in d.get("ai", []):
			var art: String = ai_entry[0]
			check(SpeciesCatalog.exists(art), "szene '" + n + "': Art '" + art + "' existiert")
		for part_entry: Array in d.get("parts", []):
			var teil: String = part_entry[0]
			check(PartCatalog.exists(teil), "szene '" + n + "': Teil '" + teil + "' existiert")


func test_argumente() -> void:
	check_eq(DemoScenes.requested(PackedStringArray(["--szene=gift"])), "gift", "szene=gift ergibt 'gift'")
	check_eq(DemoScenes.requested(PackedStringArray(["--szene=quatsch"])), "", "unbekannte Szene ergibt ''")
	check_eq(DemoScenes.requested(PackedStringArray([])), "", "leere Argumente ergeben ''")


func test_aufbau() -> void:
	check_eq(DemoScenes.build_for("tempo").parts.size(), 4, "tempo hat 4 Teile (2 Start + 2 Geißeln)")
	check_eq(DemoScenes.build_for("jagd").parts.size(), 2, "jagd hat 2 Teile (Start ohne Zusatzteile)")
	check_eq(DemoScenes.build_for("flucht").mouths()[0], "kiefer", "Fleischfresser bekommt Kiefer")
