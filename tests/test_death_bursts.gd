extends "res://tests/base_test.gd"

var d: DeathBursts

func setup() -> void:
	d = DeathBursts.new()


func test_platzen() -> void:
	d.add(Vector2(5, 5), 10.0, Color.RED)
	check_eq(d.bursts.size(), 1, "genau eine Explosion")
	check_eq(d.bursts[0]["radius"], 10.0, "Radius korrekt gespeichert")


func test_altern() -> void:
	d.add(Vector2.ZERO, 10.0, Color.RED)
	d.tick(0.3)
	check_eq(d.bursts.size(), 1, "immer noch vorhanden nach 0.3")
	check_eq(d.bursts[0]["age"], 0.3, "Alter erhöht")
	d.tick(0.4)
	check_eq(d.bursts.size(), 0, "nach insgesamt 0.7 entfernt (länger als DURATION=0.6)")


func test_hoechstzahl() -> void:
	for i in range(15):
		d.add(Vector2.ZERO, 5.0, Color.RED)
	check_eq(d.bursts.size(), 12, "maximal 12 Explosionen erlaubt")


func test_fortschritt() -> void:
	check_eq(DeathBursts.progress(0.0), 0.0, "Anfang bei 0")
	check_eq(DeathBursts.progress(0.3), 0.5, "Mitte bei 0.5")
	check_eq(DeathBursts.progress(5.0), 1.0, "Ende auf 1 gekappt")


func test_bruchstuecke() -> void:
	var p := DeathBursts.pieces(Vector2.ZERO, 10.0, 0.0)
	check_eq(p.size(), 10, "10 Bruchstücke")
	check(p[0].is_equal_approx(Vector2(5, 0)), "erstes Stück bei (5,0)")
	check(DeathBursts.pieces(Vector2(1, 1), 10.0, 0.6)[0].is_equal_approx(Vector2(21, 1)), "bei Progress 0.5: dist=15, offset 1")


func test_groesse() -> void:
	check_eq(DeathBursts.piece_size(10.0, 0.0), 3.0, "Anfangsgröße 3.0")
	check_eq(DeathBursts.piece_size(10.0, 0.3), 1.5, "Mitte bei 1.5")


func test_view() -> void:
	var v := DeathBurstView.new()
	v.bursts.add(Vector2.ZERO, 10.0, Color.RED)
	v._process(1.0)
	check_eq(v.bursts.bursts.size(), 0, "nach 1.0 kein Burst mehr")
	v.free()
