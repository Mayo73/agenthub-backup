extends "res://tests/base_test.gd"

var view: DeepGiantView


func setup() -> void:
	view = DeepGiantView.new()


func teardown() -> void:
	view.free()


func test_umriss() -> void:
	var o := DeepGiantView.outline(Vector2.ZERO, 100.0, 1.0, 0.0)
	check_eq(o.size(), 24, "o.size() ist 24")
	check(o[0].is_equal_approx(Vector2(100, 0)), "o[0] ist (100, 0)")
	check(o[6].is_equal_approx(Vector2(0, 100)), "o[6] ist (0, 100)")


func test_gestreckt() -> void:
	var o := DeepGiantView.outline(Vector2(10, 0), 100.0, 2.0, 0.0)
	check(o[0].is_equal_approx(Vector2(210, 0)), "o[0] ist (210, 0)")
	check(o[6].is_equal_approx(Vector2(10, 50)), "o[6] ist (10, 50)")


func test_gedreht() -> void:
	var o := DeepGiantView.outline(Vector2.ZERO, 100.0, 1.0, PI / 2.0)
	check(o[0].is_equal_approx(Vector2(0, 100)), "o[0] ist (0, 100)")


func test_neu() -> void:
	var v := DeepGiantView.new()
	check_eq(v.giants.giants.size(), 3, "v.giants.giants.size() ist 3")
	check(v.camera == null, "v.camera == null")
	v.free()


func test_bewegt() -> void:
	var v := DeepGiantView.new()
	var vor: Vector2 = v.giants.giants[0]["pos"]
	v._process(1.0)
	check(v.giants.giants[0]["pos"] != vor, "Position hat sich geändert")
	v.free()
