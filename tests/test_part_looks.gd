extends "res://tests/base_test.gd"

func test_alle_teile() -> void:
	for id in PartCatalog.ids():
		check(PartLooks.shape(id).size() >= 3, "Form von '%s' hat mindestens 3 Punkte" % id)
		check(PartLooks.COLORS.has(id), "Farbe '%s' ist in COLORS" % id)


func test_unbekannt() -> void:
	check(PartLooks.shape("gibtsnicht").size() == 0, "Unbekannte ID gibt leere Form zurück")
	check(PartLooks.color("gibtsnicht") == Color.WHITE, "Unbekannte ID gibt WHITE als Farbe zurück")


func test_maeuler_verschieden() -> void:
	check(PartLooks.shape("filtermaul").size() == 6, "Filtermaul hat 6 Punkte")
	check(PartLooks.shape("kiefer").size() == 7, "Kiefer hat 7 Punkte")
	check(PartLooks.shape("ruessel").size() == 5, "Rüssel hat 5 Punkte")


func test_rund() -> void:
	var g := PartLooks.shape("gift")
	check(g.size() == 8, "Gift hat 8 Punkte")
	check(g[0].is_equal_approx(Vector2(0.2, 0)), "Erster Punkt von Gift ist (0.2, 0)")


func test_farbe() -> void:
	check(PartLooks.color("gift").is_equal_approx(Color(0.55, 0.85, 0.25)), "Farbe von 'gift' ist korrekt")


func test_stachel_nach_aussen() -> void:
	var p := PartLooks.placed({"id": "stachel", "pos": Vector2(0, 1), "angle": 0.0}, 10.0)
	check(p[1].is_equal_approx(Vector2(0, 17)), "Stachel zeigt nach außen")


func test_duese_haengt_nach_aussen() -> void:
	var p := PartLooks.placed({"id": "duese", "pos": Vector2(-1, 0), "angle": 0.0}, 10.0)
	check(p[1].is_equal_approx(Vector2(-13.5, 2.0)), "Düse hängt nach außen")


func test_maul_gedreht() -> void:
	var p := PartLooks.placed({"id": "ruessel", "pos": Vector2(1, 0), "angle": PI / 2.0}, 10.0)
	check(p[2].is_equal_approx(Vector2(10, 6)), "Maul ist gedreht")
