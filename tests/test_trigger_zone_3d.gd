extends "res://tests/base_test.gd"

var zone: TriggerZone3D


func setup() -> void:
	zone = TriggerZone3D.new("test_zone", AABB(Vector3(0, 0, 0), Vector3(2, 2, 2)))


func teardown() -> void:
	pass


func test_betreten() -> void:
	var result = zone.update(1, {"a": Vector3(1, 1, 1)})
	check_eq(result.size(), 1, "ein Ereignis für Betreten")
	check_eq(result[0]["type"], "entered", "Typ ist entered")
	check_eq(result[0]["step"], 1, "step ist 1")
	check(is_inside("a"), "is_inside('a') ist wahr")


func test_verlassen() -> void:
	zone.update(1, {"a": Vector3(1, 1, 1)})
	var result = zone.update(2, {"a": Vector3(5, 1, 1)})
	check_eq(result.size(), 1, "ein Ereignis für Verlassen")
	check_eq(result[0]["type"], "exited", "Typ ist exited")


func test_hoehe_zaehlt() -> void:
	var result = zone.update(1, {"b": Vector3(1, 5, 1)})
	check_eq(result.size(), 0, "kein Ereignis (über dem Bereich)")
	check(not is_inside("b"), "is_inside('b') ist falsch")


func test_verschwunden() -> void:
	zone.update(1, {"a": Vector3(1, 1, 1)})
	var result = zone.update(2, {})
	check_eq(result.size(), 1, "ein Ereignis für verschwunden")
	check_eq(result[0]["type"], "exited", "Typ ist exited")


func test_sortiert() -> void:
	var result = zone.update(1, {"z": Vector3(1, 1, 1), "a": Vector3(1, 1, 1)})
	check_eq(result.size(), 2, "zwei Ereignisse")
	check_eq(result[0]["object"], "a", "erstes Ereignis für 'a'")
	check_eq(result[1]["object"], "z", "zweites Ereignis für 'z'")


func is_inside(object_id: String) -> bool:
	return zone.is_inside(object_id)
