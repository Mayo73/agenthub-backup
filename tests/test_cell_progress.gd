extends "res://tests/base_test.gd"

var p: CellProgress

func setup() -> void:
	p = CellProgress.new()


func test_fressen() -> void:
	var result := p.eat(4)
	check(not result, "p.eat(4) soll falsch sein")
	check_eq(p.dna, 4, "dna soll 4 sein")
	check_eq(p.growth, 4, "growth soll 4 sein")
	check_eq(p.stage, 0, "stage soll 0 sein")
	check_eq(p.growth_ratio(), 0.4, "growth_ratio soll 0.4 sein")


func test_aufsteigen() -> void:
	p.eat(4)
	var result := p.eat(6)
	check(result, "p.eat(6) soll wahr sein")
	check_eq(p.stage, 1, "stage soll 1 sein")
	check_eq(p.growth, 0, "growth soll 0 sein")
	check_eq(p.radius(), 18.0, "radius soll 18.0 sein")


func test_nichts_fressen() -> void:
	var result := p.eat(0)
	check(not result, "p.eat(0) soll falsch sein")
	check_eq(p.dna, 0, "dna soll 0 sein")


func test_viele_abschnitte() -> void:
	var result := p.eat(100)
	check(result, "p.eat(100) soll wahr sein")
	check_eq(p.stage, 4, "stage soll 4 sein")
	check_eq(p.growth, 30, "growth soll 30 sein")
	check_eq(p.dna, 100, "dna soll 100 sein")
	check(p.is_final_stage(), "is_final_stage soll wahr sein")
	check_eq(p.growth_ratio(), 1.0, "growth_ratio soll 1.0 sein")


func test_ausgeben() -> void:
	p.eat(10)
	check(p.spend(4), "p.spend(4) soll wahr sein")
	check_eq(p.dna, 6, "dna soll 6 sein nach spend(4)")
	check(not p.spend(7), "p.spend(7) soll falsch sein (nicht genug dna)")
	check_eq(p.dna, 6, "dna soll immer noch 6 sein")
	check(not p.spend(-5), "p.spend(-5) soll falsch sein")
	check_eq(p.dna, 6, "dna soll nach negativer Ausgabe unverändert bleiben")


func test_radius() -> void:
	check_eq(CellProgress.radius_for_stage(2), 27.0, "radius_for_stage(2) soll 27.0 sein")
	check_eq(CellProgress.radius_for_stage(9), 60.0, "radius_for_stage(9) soll 60.0 sein")
	check_eq(CellProgress.radius_for_stage(-1), 12.0, "radius_for_stage(-1) soll 12.0 sein")
