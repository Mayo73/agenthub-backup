extends "res://tests/base_test.gd"

var deep_giants: DeepGiants


func setup() -> void:
	deep_giants = DeepGiants.new()


func test_anzahl() -> void:
	check_eq(deep_giants.giants.size(), 3, "es sind 3 Riesen")
	for g in deep_giants.giants:
		check(g["radius"] >= 180.0 and g["radius"] <= 320.0, "radius im Bereich [180, 320]")
		check(g["pos"].x >= 0.0 and g["pos"].x < DeepGiants.AREA, "pos.x im Bereich [0, AREA)")


func test_gleicher_seed() -> void:
	var d1 := DeepGiants.new(9)
	var d2 := DeepGiants.new(9)
	check(d1.giants == d2.giants, "gleicher Seed erzeugt gleiche Daten")


func test_schritt() -> void:
	deep_giants = DeepGiants.new()
	deep_giants.giants = [{"pos": Vector2(100, 50), "radius": 200.0, "vel": Vector2(10, -5), "stretch": 1.5}]
	deep_giants.step(2.0)
	check_eq(deep_giants.giants[0]["pos"], Vector2(120, 40), "Pos nach Schritt berechnet")


func test_umfalten() -> void:
	deep_giants = DeepGiants.new()
	deep_giants.giants = [{"pos": Vector2(2390, 5), "radius": 200.0, "vel": Vector2(20, 0), "stretch": 1.5}]
	deep_giants.step(1.0)
	check_eq(deep_giants.giants[0]["pos"], Vector2(10, 5), "Pos umfalten am Rand")


func test_bildschirm() -> void:
	check_eq(DeepGiants.screen_pos(Vector2(100, 0), Vector2.ZERO, Vector2(1920, 1080)), Vector2(1060, 540), "screen_pos (100,0)")
	check_eq(DeepGiants.screen_pos(Vector2(2300, 0), Vector2.ZERO, Vector2(1920, 1080)), Vector2(860, 540), "screen_pos (2300,0)")
	check_eq(DeepGiants.screen_pos(Vector2(100, 0), Vector2(1000, 0), Vector2(1920, 1080)), Vector2(980, 540), "screen_pos mit Kamera")


func test_richtung() -> void:
	check(is_equal_approx(DeepGiants.heading({"vel": Vector2(0, 10)}), PI / 2.0), "Richtung nach unten ist PI/2")
