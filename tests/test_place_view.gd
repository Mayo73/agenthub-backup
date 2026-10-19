extends "res://tests/base_test.gd"

var view: PlaceView


func setup() -> void:
	view = PlaceView.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(view)
	view.size = Vector2(400, 220)


func teardown() -> void:
	if view:
		view.free()
		view = null


func test_anfang() -> void:
	check_eq("Draußen", view.kind, "kind ist Draußen")
	check(view.caption_label.text.contains("keine Karte"), "caption_label enthält 'keine Karte'")
	check_eq(2, view.shape_count(), "shape_count() ist 2 für Draußen")


func test_park() -> void:
	view.set_place("Stadtpark")
	check_eq("Park", view.kind, "kind ist Park nach set_place('Stadtpark')")
	check_eq(5, view.shape_count(), "shape_count() ist 5 für Park")
	check_eq("Skizze: Park (schematisch, keine Karte)", view.caption_label.text, "caption_label Text ist korrekt für Park")


func test_wechsel() -> void:
	view.set_place("Strand")
	check_eq("Strand", view.kind, "kind ist Strand")

	view.set_place("")
	check_eq("Draußen", view.kind, "kind ist Draußen nach set_place('')")


func test_mindesthoehe() -> void:
	check_eq(220, view.custom_minimum_size.y, "custom_minimum_size.y ist 220")


func test_beschriftung_ist_kind() -> void:
	check(view.caption_label.get_parent() == view, "caption_label hat view als Parent")
