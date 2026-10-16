extends "res://tests/base_test.gd"

var food_view: FoodView


func setup() -> void:
	food_view = FoodView.new()


func teardown() -> void:
	food_view.free()


func test_ruhe() -> void:
	check_eq(FoodView.bob(Vector2.ZERO, 0.0), Vector2.ZERO, "bob mit t=0 sollte 0 sein")


func test_oben() -> void:
	var bob_value := FoodView.bob(Vector2.ZERO, PI / 4.0)
	check(bob_value.is_equal_approx(Vector2(0, 1.5)), "bob mit t=PI/4 sollte (0, 1.5) sein")


func test_versetzt() -> void:
	var bob_10 := FoodView.bob(Vector2(10, 0), 0.0)
	var bob_40 := FoodView.bob(Vector2(40, 0), 0.0)
	check(not bob_10.is_equal_approx(bob_40), "bob bei x=10 und x=40 soll unterschiedlich sein")


func test_zeit() -> void:
	food_view._process(0.5)
	food_view._process(0.25)
	check_eq(food_view.time, 0.75, "time sollte 0.75 nach zwei _process-Aufrufen sein")
