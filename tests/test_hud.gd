extends "res://tests/base_test.gd"

var hud: Hud


func setup() -> void:
	hud = Hud.new()


func teardown() -> void:
	hud.free()


func test_fortschritt() -> void:
	var p := CellProgress.new()
	p.eat(5)
	hud.show_progress(p)
	check_eq(hud.dna_label.text, "DNA: 5", "dna_label zeigt richtige DNA")
	check_eq(hud.growth_bar.value, 50.0, "growth_bar value ist 50.0")
	check_eq(hud.stage_label.text, "Größe 1/5", "stage_label zeigt richtige Größe")


func test_letzte_groesse() -> void:
	var p := CellProgress.new()
	p.eat(100)
	hud.show_progress(p)
	check_eq(hud.stage_label.text, "Größe 5/5", "stage_label zeigt letzte Größe")
	check_eq(hud.growth_bar.value, 100.0, "growth_bar value ist 100.0 im letzten Abschnitt")
