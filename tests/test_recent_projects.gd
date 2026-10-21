extends "res://tests/base_test.gd"

var model: RecentProjects


func setup() -> void:
	model = RecentProjects.new()


func test_reihenfolge() -> void:
	model.add("a")
	model.add("b")
	model.add("c")
	check_eq(model.paths, ["c", "b", "a"], "Pfade sollten umgekehrt sein")


func test_doppelt() -> void:
	model.add("c:/spiele/a")
	model.add("x")
	model.add("C:\\Spiele\\A")
	var expected := ["C:/Spiele/A", "x"]
	check_eq(model.paths, expected, "Duplikate sollten entfernt sein")


func test_grenze() -> void:
	var short_limit := RecentProjects.new(2)
	short_limit.add("a")
	short_limit.add("b")
	short_limit.add("c")
	check_eq(short_limit.paths.size(), 2, "Nur die letzten 2 Pfade sollten bleiben")


func test_speichern() -> void:
	model.add("a")
	model.add("b")
	var restored := RecentProjects.from_dict(model.to_dict())
	check_eq(restored.paths, ["b", "a"], "Pfade sollten korrekt restauriert sein")
	restored.remove("B")
	check_eq(restored.paths, ["a"], "Entferntes Element sollte fehlen")
