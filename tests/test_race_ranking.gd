extends "res://tests/base_test.gd"

var timer: LapTimer


func setup() -> void:
	timer = LapTimer.new(1000.0)


func test_strecke_erste_runde() -> void:
	timer.update(0.1, 100.0)
	check_eq(timer.distance(), 100.0, "Strecke in erster Runde")


func test_hinter_der_ziellinie() -> void:
	timer.update(0.1, 950.0)
	check_eq(timer.distance(), -50.0, "Position hinter der Ziellinie vor erstem Half-Pass")


func test_nach_einer_runde() -> void:
	timer.update(1.0, 100.0)
	timer.update(1.0, 500.0)
	timer.update(1.0, 900.0)
	timer.update(1.0, 50.0)
	check_eq(timer.lap, 1, "Lap-Zähler")
	check_eq(timer.distance(), 1050.0, "Strecke nach einer Runde")


func test_platz() -> void:
	check_eq(RaceRanking.place(500.0, [100.0, 600.0, 300.0]), 2, "Platz bei gemischten Strecken")
	check_eq(RaceRanking.place(700.0, [100.0, 600.0]), 1, "Platz vorn")
	check_eq(RaceRanking.place(0.0, [10.0, 20.0, 30.0]), 4, "Platz ganz hinten")
