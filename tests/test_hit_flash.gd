extends "res://tests/base_test.gd"

var f: HitFlash


func setup() -> void:
	f = HitFlash.new()


func test_ruhe() -> void:
	check_eq(f.amount(), 0.0, "amount() ist 0.0 im Ruhezustand")
	check(not f.is_active(), "is_active() ist falsch im Ruhezustand")
	check_eq(f.overlay_color().a, 0.0, "overlay_color().a ist 0.0 im Ruhezustand")


func test_treffer() -> void:
	f.trigger()
	check_eq(f.amount(), 1.0, "amount() ist 1.0 nach Treffer")
	check(f.is_active(), "is_active() ist wahr nach Treffer")
	check_eq(f.overlay_color().a, 0.5, "overlay_color().a ist 0.5 nach Treffer")


func test_abklingen() -> void:
	f.trigger()
	f.tick(0.125)
	check_eq(f.amount(), 0.5, "amount() ist 0.5 nach tick(0.125)")
	f.tick(1.0)
	check_eq(f.amount(), 0.0, "amount() ist 0.0 nach tick(1.0)")
	check(not f.is_active(), "is_active() ist falsch nach vollständigem Abklingen")


func test_erneut() -> void:
	f.trigger()
	f.tick(0.2)
	f.trigger()
	check_eq(f.amount(), 1.0, "amount() ist 1.0 nach erneutem Treffer")
