extends "res://tests/base_test.gd"


func test_keiner() -> void:
	check(is_inf(FishThreat.nearest_predator(Vector3(0, -20, 0), [])), "Keine Fische → INF")


func test_nur_beute() -> void:
	var f := AiFish.new()
	f.setup("silberling", Vector3(3, -20, 0))
	check(is_inf(FishThreat.nearest_predator(Vector3(0, -20, 0), [f])), "Nur Beutefisch → INF")
	f.free()


func test_naechster() -> void:
	var a := AiFish.new()
	var b := AiFish.new()
	a.setup("zackenbarsch", Vector3(10, -20, 0))
	b.setup("zackenbarsch", Vector3(0, -20, 30))
	check_eq(FishThreat.nearest_predator(Vector3(0, -20, 0), [a, b]), 10.0, "Nächster Raubfisch = 10.0")
	a.free()
	b.free()


func test_warnung() -> void:
	check(FishThreat.is_warning(15.0), "is_warning(15.0) wahr")
	check(not FishThreat.is_warning(15.1), "is_warning(15.1) falsch")
	check(not FishThreat.is_warning(INF), "is_warning(INF) falsch")


func test_text() -> void:
	check_eq(FishThreat.warning_text(9.6), "Vorsicht: Raubfisch in 10 m!", "warning_text(9.6)")
	check_eq(FishThreat.warning_text(20.0), "", "warning_text(20.0) leer")
	check_eq(FishThreat.warning_text(INF), "", "warning_text(INF) leer")
