extends "res://tests/base_test.gd"


func setup() -> void:
	GameSettings.track_id = TrackCatalog.DEFAULT_ID


func teardown() -> void:
	GameSettings.track_id = TrackCatalog.DEFAULT_ID


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
