extends "res://tests/base_test.gd"

var ui: UiLayout


func setup() -> void:
	ui = UiLayout.new()


func test_anlegen() -> void:
	var result := ui.add("start", "button", Rect2(0, 0, 100, 40), "Start")
	check(result.is_ok(), "erster Knopf wird angelegt")

	result = ui.add("start", "button", Rect2(0, 0, 100, 40), "Start")
	check(not result.is_ok() and result.code == CommandResult.CONFLICT, "gleiche Kennung → CONFLICT")

	result = ui.add("x", "knopf", Rect2())
	check(not result.is_ok() and result.code == CommandResult.INVALID_ARGUMENT, "unbekannte Art → INVALID_ARGUMENT")


func test_treffer() -> void:
	ui.add("a", "button", Rect2(0, 0, 100, 40))
	ui.add("b", "button", Rect2(50, 0, 100, 40))
	ui.add("titel", "label", Rect2(0, 100, 100, 20))

	check(ui.hit_test(Vector2(60, 10)) == "b", "Punkt (60, 10) in 'b' → 'b'")
	check(ui.hit_test(Vector2(10, 10)) == "a", "Punkt (10, 10) nur in 'a' → 'a'")
	check(ui.hit_test(Vector2(10, 110)) == "", "Punkt (10, 110) nur im Label → ''")
	check(ui.hit_test(Vector2(500, 500)) == "", "Punkt (500, 500) überall → ''")


func test_gesperrt() -> void:
	ui.add("a", "button", Rect2(0, 0, 100, 40))
	ui.add("b", "button", Rect2(50, 0, 100, 40))

	ui.set_enabled("b", false)

	check(ui.hit_test(Vector2(60, 10)) == "a", "b gesperrt, Punkt (60, 10) → 'a'")


func test_regler() -> void:
	ui.add("lautstaerke", "slider", Rect2(0, 0, 100, 20))
	ui.add("a", "button", Rect2(0, 0, 100, 40))

	var result_val: float = ui.set_value("lautstaerke", 1.5)
	check_eq(result_val, 1.0, "set_value über 1.0 → 1.0")

	var element := ui.find("lautstaerke")
	check_eq(element["value"], 1.0, "find('lautstaerke')['value'] → 1.0")

	result_val = ui.set_value("a", 0.5)
	check_eq(result_val, -1.0, "set_value für Knopf → -1.0")


func test_reihenfolge() -> void:
	ui.add("unten", "button", Rect2(0, 100, 50, 20))
	ui.add("rechts", "button", Rect2(200, 0, 50, 20))
	ui.add("links", "button", Rect2(0, 0, 50, 20))

	var order := ui.focus_order()
	check(order.size() == 3, "focus_order hat 3 Einträge")

	check(order[0] == "links", "focus_order[0] → 'links'")
	check(order[1] == "rechts", "focus_order[1] → 'rechts'")
	check(order[2] == "unten", "focus_order[2] → 'unten'")
