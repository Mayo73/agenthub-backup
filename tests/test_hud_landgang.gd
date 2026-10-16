extends "res://tests/base_test.gd"

var hud: Hud
var p: CellProgress


func setup() -> void:
	hud = Hud.new()
	p = CellProgress.new()


func teardown() -> void:
	hud.free()


func test_vorher() -> void:
	p.eat(5)
	hud.show_progress(p)
	check_eq(hud.growth_bar.value, 50.0, "Fortsritt im ersten Abschnitt ist 50%")


func test_letzter_abschnitt() -> void:
	p.eat(70)
	hud.show_progress(p)
	check_eq(hud.growth_bar.value, 0.0, "Balken zeigt 0 beim Übergang zur letzten Phase")
	check_eq(hud.stage_label.text, "Größe 5/5", "Etage-Label zeigt Größe 5/5")


func test_halb() -> void:
	p.eat(70)
	p.eat(15)
	hud.show_progress(p)
	check_eq(hud.growth_bar.value, 50.0, "Fortsritt in der letzten Phase ist 50%")
