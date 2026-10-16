extends "res://tests/base_test.gd"

var p: CellProgress


func setup() -> void:
	p = CellProgress.new()


func test_am_anfang() -> void:
	check(not PhaseEnd.can_finish(p), "can_finish am Anfang falsch")
	check_eq(PhaseEnd.ratio(p), 0.0, "ratio am Anfang ist 0.0")


func test_letzter_abschnitt() -> void:
	p.eat(70)
	check(p.is_final_stage(), "p ist nicht im letzten Abschnitt")
	check(not PhaseEnd.can_finish(p), "can_finish im letzten Abschnitt falsch")
	check_eq(PhaseEnd.ratio(p), 0.0, "ratio vor FINAL_GROWTH ist 0.0")


func test_fertig() -> void:
	p.eat(70)
	p.eat(15)
	check_eq(PhaseEnd.ratio(p), 0.5, "ratio nach 85 sollte 0.5 sein")
	p.eat(15)
	check(PhaseEnd.can_finish(p), "can_finish falsch sobald FINAL_GROWTH erreicht")
	check_eq(PhaseEnd.ratio(p), 1.0, "ratio bei FINAL_GROWTH ist 1.0")
	p.eat(20)
	check_eq(PhaseEnd.ratio(p), 1.0, "ratio nach Überschuss ist immer noch 1.0")
