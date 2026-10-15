extends "res://tests/base_test.gd"


func test_startet_bei_null() -> void:
	var state := GameState.new()
	check_eq(state.score, 0, "Startpunktzahl")
	check_eq(state.coins_collected, 0, "Start-Münzen")


func test_muenze_erhoeht_punkte() -> void:
	var state := GameState.new()
	state.add_coin()
	state.add_coin(5)
	check_eq(state.score, 6, "Punkte nach zwei Münzen")
	check_eq(state.coins_collected, 2, "Anzahl Münzen")


func test_reset() -> void:
	var state := GameState.new()
	state.add_coin(3)
	state.reset()
	check_eq(state.score, 0, "Punkte nach Reset")
	check_eq(state.coins_collected, 0, "Münzen nach Reset")


func test_signal_bei_punkten() -> void:
	var state := GameState.new()
	var received := []
	state.score_changed.connect(func(s: int) -> void: received.append(s))
	state.add_coin(2)
	check_eq(received, [2], "Werte aus score_changed")
