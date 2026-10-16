extends "res://tests/base_test.gd"

var hud: Hud


func setup() -> void:
	hud = Hud.new()


func teardown() -> void:
	hud.free()


func test_verborgen() -> void:
	check(not hud.finish_button.visible, "finish_button ist nicht verborgen")
	check_eq(hud.finish_button.text, "An Land gehen", "text ist 'An Land gehen'")


func test_zeigen() -> void:
	hud.show_can_finish(true)
	check(hud.finish_button.visible, "finish_button sichtbar nach show_can_finish(true)")
	hud.show_can_finish(false)
	check(not hud.finish_button.visible, "finish_button unsichtbar nach show_can_finish(false)")


func test_signal() -> void:
	var got: Array = []
	hud.finish_pressed.connect(func() -> void: got.append(1))
	hud.finish_button.pressed.emit()
	check_eq(got.size(), 1, "signal wurde ausgelöst")
