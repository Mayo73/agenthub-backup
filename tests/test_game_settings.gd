extends "res://tests/base_test.gd"


func setup() -> void:
	GameSettings.track_id = TrackCatalog.DEFAULT_ID
	GameSettings.car_id = CarCatalog.DEFAULT_ID


func teardown() -> void:
	GameSettings.track_id = TrackCatalog.DEFAULT_ID
	GameSettings.car_id = CarCatalog.DEFAULT_ID


func test_naechste_strecke() -> void:
	GameSettings.next_track()
	check_eq(GameSettings.track_id, "altstadt", "erste naechte Strecke")
	GameSettings.next_track()
	check_eq(GameSettings.track_id, "kurvenring", "zweite naechte Strecke")
	GameSettings.next_track()
	check_eq(GameSettings.track_id, "hafen", "dritte naechte Strecke (Zyklus)")


func test_vorherige_strecke() -> void:
	GameSettings.previous_track()
	check_eq(GameSettings.track_id, "kurvenring", "vorherige Strecke von hafen")


func test_step_id_unbekannt() -> void:
	var ids: Array[String] = ["a", "b"]
	check_eq(GameSettings.step_id(ids, "x", 1), "a", "unbekannt mit dir=1 gibt ersten Eintrag")
	check_eq(GameSettings.step_id(ids, "b", 1), "a", "letzter mit dir=1 gibt ersten Eintrag (Zyklus)")
	check_eq(GameSettings.step_id(ids, "a", -1), "b", "erster mit dir=-1 gibt letzten Eintrag (Zyklus)")


func test_standardauto() -> void:
	check_eq(GameSettings.car_id, "allround", "standard auto ist allround")


func test_naechstes_auto() -> void:
	GameSettings.next_car()
	check_eq(GameSettings.car_id, "grip", "erstes naechstes Auto")
	GameSettings.next_car()
	check_eq(GameSettings.car_id, "drifter", "zweites naechstes Auto")
	GameSettings.next_car()
	check_eq(GameSettings.car_id, "allround", "drittes naechstes Auto (Zyklus)")


func test_vorheriges_auto() -> void:
	GameSettings.previous_car()
	check_eq(GameSettings.car_id, "drifter", "vorheriges Auto von allround")
