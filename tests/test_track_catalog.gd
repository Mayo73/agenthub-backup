extends "res://tests/base_test.gd"

var catalog: TrackCatalog


func setup() -> void:
	catalog = TrackCatalog.new()


func test_standardstrecke() -> void:
	check(catalog.has_track(TrackCatalog.DEFAULT_ID), "DEFAULT_ID sollte existieren")
	var ids := catalog.ids()
	check(ids.has("hafen"), "ids() sollte 'hafen' enthalten")


func test_hafenring() -> void:
	check_eq(catalog.name_of("hafen"), "Hafenring", "name_of('hafen') sollte Hafenring sein")
	check_eq(catalog.width_of("hafen"), 280.0, "width_of('hafen') sollte 280.0 sein")
	var points := catalog.points_of("hafen")
	check_eq(points.size(), 13, "points_of('hafen').size() sollte 13 sein")
	check_eq(points[1], Vector2(1400, 0), "points_of('hafen')[1] sollte Vector2(1400, 0) sein")


func test_unbekannt() -> void:
	check(not catalog.has_track("gibtsnicht"), "has_track('gibtsnicht') sollte falsch sein")
	check_eq(catalog.name_of("gibtsnicht"), "", "name_of('gibtsnicht') sollte '' sein")
	check_eq(catalog.points_of("gibtsnicht").size(), 0, "points_of('gibtsnicht').size() sollte 0 sein")
	check_eq(catalog.width_of("gibtsnicht"), 280.0, "width_of('gibtsnicht') sollte 280.0 sein")


func test_jede_strecke_hat_genug_punkte() -> void:
	for id in catalog.ids():
		check(catalog.points_of(id).size() >= 4, "Strecke '" + id + "' sollte mindestens 4 Punkte haben")
		check(catalog.name_of(id) != "", "Strecke '" + id + "' sollte einen Namen haben")
