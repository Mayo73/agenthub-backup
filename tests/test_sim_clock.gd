extends "res://tests/base_test.gd"

var clock: SimClock
var stepped_count := 0


func setup() -> void:
	clock = SimClock.new()
	stepped_count = 0
	clock.stepped.connect(_on_stepped)


func teardown() -> void:
	pass


func _on_stepped(_step: int) -> void:
	stepped_count += 1


func test_pausiert() -> void:
	var result := clock.advance(1.0)
	check_eq(result, 0, "advance bei pausiert sollte 0")
	check_eq(clock.step_count, 0, "step_count sollte 0 bleiben")


func test_laufen() -> void:
	clock.start()
	var result := clock.advance(0.051)
	check_eq(result, 6, "advance sollte 6 Schritte machen")
	check_eq(clock.step_count, 6, "step_count sollte 6 sein")
	check_eq(stepped_count, 6, "stepped_signal sollte 6 mal gesendet worden sein")


func test_rest_bleibt() -> void:
	clock.start()
	var result1 := clock.advance(0.004)
	check_eq(result1, 0, "erste advance sollte 0 Schritte machen")

	var result2 := clock.advance(0.005)
	check_eq(result2, 1, "zweite advance sollte 1 Schritt machen")


func test_grenze() -> void:
	clock.start()
	var result := clock.advance(5.0)
	check_eq(result, 12, "advance bei großer Delta sollte MAX_STEPS_PER_ADVANCE machen")
	# accumulator nach Erreichen der Grenze sollte auf 0 sein
	var state := clock.state()
	check_eq(state["step"], 12, "step_count sollte 12 sein")


func test_einzelschritt() -> void:
	var result1 := clock.step(1)
	check_eq(result1, 1, "step(1) sollte 1 zurückgeben")

	var result2 := clock.step(3)
	check_eq(result2, 3, "step(3) sollte 3 zurückgeben")

	check_eq(clock.step_count, 4, "step_count sollte 4 sein")

	var expected_time := 4.0 / SimClock.HZ
	check_eq(clock.time(), expected_time, "time() sollte korrekt sein")

	var result3 := clock.step(0)
	check_eq(result3, 0, "step(0) sollte 0 zurückgeben")


func test_zustand() -> void:
	clock.start()
	clock.step(120)
	var state := clock.state()
	check_eq(state["running"], true, "state.running sollte wahr sein")
	check_eq(state["step"], 120, "state.step sollte 120 sein")
	check_eq(state["time"], 1.0, "state.time sollte 1.0 sein")

	clock.reset()
	state = clock.state()
	check_eq(state["running"], false, "nach reset sollte running falsch sein")
	check_eq(state["step"], 0, "nach reset sollte step 0 sein")
