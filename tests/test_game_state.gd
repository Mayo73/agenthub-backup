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


func test_highscore_steigt_mit_punkten() -> void:
	var state := GameState.new()
	state.add_coin(2)
	state.add_coin(3)
	check_eq(state.high_score, 5, "Highscore nach Münzen")


func test_highscore_bleibt_nach_reset() -> void:
	var state := GameState.new()
	state.add_coin(4)
	state.reset()
	check_eq(state.score, 0, "Punkte nach Reset")
	check_eq(state.high_score, 4, "Highscore bleibt erhalten")


func test_highscore_signal_nur_bei_neuem_rekord() -> void:
	var state := GameState.new()
	var received := []
	state.high_score_changed.connect(func(s: int) -> void: received.append(s))
	state.add_coin(4)
	state.reset()
	state.add_coin(2)
	check_eq(received, [4], "Signal nur bei neuem Rekord")


func test_durchschnitt_ohne_muenzen() -> void:
	var state := GameState.new()
	check_eq(state.average_coin_value(), 0.0, "Durchschnitt ohne Münzen")


func test_durchschnitt() -> void:
	var state := GameState.new()
	state.add_coin(1)
	state.add_coin(3)
	check_eq(state.average_coin_value(), 2.0, "Durchschnitt nach zwei Münzen")
