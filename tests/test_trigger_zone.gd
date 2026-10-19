extends "res://tests/base_test.gd"

var zone: TriggerZone


func setup() -> void:
	zone = TriggerZone.new("ziel", Rect2(0, 0, 10, 10))


func test_betreten() -> void:
	var events = zone.update(1, {"a": Vector2(5, 5)})
	check(events.size() == 1, "ein Ereignis")

	if events.size() > 0:
		check(events[0]["type"] == "entered", "Typ 'entered'")
		check(events[0]["step"] == 1, "step 1")

	check(zone.is_inside("a"), "is_inside('a') wahr")


func test_kein_doppeltes() -> void:
	var events1 = zone.update(1, {"a": Vector2(5, 5)})
	check(events1.size() == 1, "erstes Mal ein Ereignis")

	zone.clear()
	var events2 = zone.update(1, {"a": Vector2(5, 5)})
	check(events2.size() == 1, "zweites Mal bei gleicher Position auch ein Ereignis (da cleared)")

	# Zweimal denselben Punkt ohne clear dazwischen
	events2 = zone.update(1, {"a": Vector2(5, 5)})
	check(events2.is_empty(), "leere Liste beim zweiten Aufruf")


func test_verlassen() -> void:
	zone.update(1, {"a": Vector2(5, 5)})
	check(zone.is_inside("a"), "a ist drin")

	var events = zone.update(2, {"a": Vector2(20, 5)})
	check(events.size() == 1, "ein Ereignis beim Verlassen")

	if events.size() > 0:
		check(events[0]["type"] == "exited", "Typ 'exited'")

	check(not zone.is_inside("a"), "is_inside('a') falsch")


func test_verschwunden() -> void:
	zone.update(1, {"a": Vector2(5, 5)})
	check(zone.is_inside("a"), "a ist drin")

	var events = zone.update(2, {})
	check(events.size() == 1, "ein Ereignis beim Verschwinden")

	if events.size() > 0:
		check(events[0]["type"] == "exited", "Typ 'exited'")


func test_reihenfolge() -> void:
	zone.clear()
	var events = zone.update(1, {"b": Vector2(1, 1), "a": Vector2(2, 2)})
	check(events.size() == 2, "events.size() 2")

	if events.size() >= 2:
		check(events[0]["object"] == "a", "erstes Objekt 'a' (sortiert)")
		check(events[1]["object"] == "b", "zweites Objekt 'b' (sortiert)")


func test_wieder_betreten() -> void:
	zone.update(1, {"a": Vector2(5, 5)})
	zone.update(2, {"a": Vector2(20, 5)})
	var events: Array[Dictionary] = zone.update(3, {"a": Vector2(5, 5)})
	check_eq(events.size(), 1, "erneutes Betreten meldet ein Ereignis")
	if events.size() > 0:
		check_eq(events[0]["type"], "entered", "Typ 'entered' beim zweiten Betreten")
	check(zone.is_inside("a"), "a ist wieder drin")
