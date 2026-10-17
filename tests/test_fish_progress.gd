extends "res://tests/base_test.gd"

var p: FishProgress

func setup() -> void:
	p = FishProgress.new()


func test_start() -> void:
	check_eq(p.dna, 0, "dna ist Anfang 0")
	check_eq(p.stage, 0, "stage ist Anfang 0")
	check_eq(p.size(), 1.0, "size ist Anfang 1.0")
	check_eq(p.growth_ratio(), 0.0, "growth_ratio ist Anfang 0.0")


func test_fressen() -> void:
	var result := p.eat(5)
	check(not result, "p.eat(5) falsch")
	check_eq(p.dna, 5, "dna nach eat(5) ist 5")
	check_eq(p.growth, 5, "growth nach eat(5) ist 5")
	check_eq(p.growth_ratio(), 0.25, "growth_ratio nach eat(5) ist 0.25")


func test_wachsen() -> void:
	var r1 := p.eat(19)
	check(not r1, "p.eat(19) falsch")
	var r2 := p.eat(3)
	check(r2, "p.eat(3) wahr")
	check_eq(p.stage, 1, "stage nach Wachstum ist 1")
	check_eq(p.growth, 2, "growth nach Wachstum ist 2")
	check_eq(p.size(), 1.4, "size nach Wachstum ist 1.4")
	check_eq(p.dna, 22, "dna nach Wachstum ist 22")


func test_mehrere_stufen() -> void:
	p = FishProgress.new()
	var r := p.eat(60)
	check(r, "p.eat(60) wahr")
	check_eq(p.stage, 2, "stage nach mehreren Stufen ist 2")
	check_eq(p.growth, 10, "growth nach mehreren Stufen ist 10")


func test_letzte_groesse() -> void:
	p = FishProgress.new()
	p.eat(500)
	check(p.is_final_stage(), "is_final_stage wahr nach viel Essen")
	check_eq(p.size(), 2.5, "size ist 2.5 in letzter Größe")
	check_eq(p.growth_ratio(), 1.0, "growth_ratio ist 1.0 in letzter Größe")


func test_nichts() -> void:
	p = FishProgress.new()
	var r1 := p.eat(0)
	check(not r1, "p.eat(0) falsch")
	var r2 := p.eat(-3)
	check(not r2, "p.eat(-3) falsch")
	check_eq(p.dna, 0, "dna nach negativen/0 Werten ist 0")


func test_ausgeben() -> void:
	p = FishProgress.new()
	p.eat(10)
	var s1 := p.spend(4)
	check(s1, "p.spend(4) wahr")
	check_eq(p.dna, 6, "dna nach spend(4) ist 6")
	var s2 := p.spend(7)
	check(not s2, "p.spend(7) falsch")
	var s3 := p.spend(-1)
	check(not s3, "p.spend(-1) falsch")
	check_eq(p.dna, 6, "dna nach negativer Ausgabe bleibt 6")
