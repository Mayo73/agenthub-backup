extends "res://tests/base_test.gd"

var model: SceneModel

func setup() -> void:
	model = SceneModel.new()


func test_gleich() -> void:
	var result := SceneDiff.diff(model.to_dict(), model.to_dict())
	check_eq(result.size(), 0, "bei gleichen Schnappschüssen keine Änderungen")


func test_neu() -> void:
	var a: Dictionary = model.to_dict().duplicate(true)
	model.add_object("Node2D")
	var b: Dictionary = model.to_dict()
	var result := SceneDiff.diff(a, b)
	check_eq(result.size(), 1, "ein Eintrag bei neuem Objekt")
	check_eq(result[0]["op"], "added", "Operation ist 'added'")
	check_eq(result[0]["id"], "o1", "ID ist o1")
	check_eq(result[0]["type"], "Node2D", "Typ ist Node2D")


func test_entfernt() -> void:
	model.add_object("Node2D")
	var snapshot := model.to_dict().duplicate(true)
	model.remove_object("o1")
	var result := SceneDiff.diff(snapshot, model.to_dict())
	check_eq(result.size(), 1, "ein Eintrag bei entferntem Objekt")
	check_eq(result[0]["op"], "removed", "Operation ist 'removed'")
	check_eq(result[0]["id"], "o1", "ID ist o1")


func test_geaendert() -> void:
	model.add_object("Node2D", "", {"mass": 1.0})
	var snapshot := model.to_dict().duplicate(true)
	model.set_property("o1", "mass", 2.0)
	var result := SceneDiff.diff(snapshot, model.to_dict())
	check_eq(result.size(), 1, "ein Eintrag bei geänderter Eigenschaft")
	check_eq(result[0]["op"], "changed", "Operation ist 'changed'")
	check_eq(result[0]["key"], "mass", "Schlüssel ist mass")
	check_eq(result[0]["old"], 1.0, "alter Wert ist 1.0")
	check_eq(result[0]["new"], 2.0, "neuer Wert ist 2.0")


func test_zusammenfassung() -> void:
	var changes: Array[Dictionary] = [
		{"op": "added"},
		{"op": "changed"}
	]
	var s := SceneDiff.summary(changes)
	check_eq(s, "1 neu, 0 entfernt, 0 verschoben, 1 geändert", "Zusammenfassung stimmt")
