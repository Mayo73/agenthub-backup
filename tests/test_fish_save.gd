extends "res://tests/base_test.gd"


func test_hin_und_zurueck() -> void:
	var b := FishBuild.new()
	b.upgrade("kiefer")
	b.diet = Diet.FLEISCHFRESSER
	var p := FishProgress.new()
	p.dna = 42
	p.growth = 7
	p.stage = 2
	var d := FishSave.to_dict(b, p)
	var p2 := FishProgress.new()
	var b2 := FishSave.apply(d, p2)
	check_eq(p2.dna, 42, "dna wurde übernommen")
	check_eq(p2.growth, 7, "growth wurde übernommen")
	check_eq(p2.stage, 2, "stage wurde übernommen")
	check_eq(b2.level("kiefer"), 1, "kiefer-Level wurde übernommen")
	check_eq(b2.diet, Diet.FLEISCHFRESSER, "diet wurde übernommen")


func test_leer() -> void:
	var p := FishProgress.new()
	var b := FishSave.apply({}, p)
	check_eq(p.dna, 0, "dna ist 0 bei leerem Dictionary")
	check_eq(p.stage, 0, "stage ist 0 bei leerem Dictionary")
	check_eq(b.total_levels(), 0, "total_levels ist 0 bei leerem Dictionary")


func test_begrenzt() -> void:
	var p := FishProgress.new()
	FishSave.apply({"stage": 9, "dna": -5}, p)
	check_eq(p.stage, 3, "stage ist begrenzt auf 3")
	check_eq(p.dna, 0, "dna ist mindestens 0")


func test_hat_fisch() -> void:
	check(FishSave.has_fish({"fish": {}}), "hat_fisch wahr bei Dictionary als fish-Wert")
	check(not FishSave.has_fish({}), "hat_fisch falsch bei leerem Dictionary")
	check(not FishSave.has_fish({"fish": 3}), "hat_fisch falsch bei Integer als fish-Wert")
