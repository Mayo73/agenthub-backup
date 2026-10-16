extends "res://tests/base_test.gd"
## Tests für CellLook (Aussehen des Zellkörpers)

var look: CellLook


func setup() -> void:
	look = CellLook.new()


func test_standard() -> void:
	check_eq(look.pattern, "keins", "pattern sollte 'keins' sein")
	check_eq(look.stretch, 1.0, "stretch sollte 1.0 sein")
	check(look.color.is_equal_approx(CellLook.DEFAULT_COLOR), "color sollte DEFAULT_COLOR sein")


func test_muster() -> void:
	check(look.set_pattern("punkte"), "set_pattern('punkte') sollte true zurückgeben")
	check_eq(look.pattern, "punkte", "pattern sollte 'punkte' sein")
	check(not look.set_pattern("karo"), "set_pattern('karo') sollte false zurückgeben")
	check_eq(look.pattern, "punkte", "pattern sollte nach Fehler unverändert 'punkte' bleiben")


func test_streckung_begrenzt() -> void:
	look = CellLook.new()
	look.set_stretch(3.0)
	check_eq(look.stretch, 1.5, "stretch sollte auf MAX_STRETCH (1.5) begrenzt sein")

	look.set_stretch(0.1)
	check_eq(look.stretch, 0.7, "stretch sollte auf MIN_STRETCH (0.7) begrenzt sein")

	look.set_stretch(1.2)
	check_eq(look.stretch, 1.2, "stretch sollte 1.2 bleiben (im gültigen Bereich)")


func test_umriss() -> void:
	look = CellLook.new()
	look.set_stretch(1.5)
	var o := look.outline(10.0, 4)

	check_eq(o.size(), 4, "outline sollte 4 Punkte haben")
	check(o[0].is_equal_approx(Vector2(15, 0)), "Punkt 0 sollte (15, 0) sein")
	check(o[1].is_equal_approx(Vector2(0, 10.0 / 1.5)), "Punkt 1 sollte (0, 10/1.5) sein")


func test_speichern_laden() -> void:
	look = CellLook.new()
	look.color = Color(1, 0, 0)
	look.set_pattern("streifen")
	look.set_stretch(1.2)

	var l2 := CellLook.from_dict(look.to_dict())

	check(l2.color.is_equal_approx(Color(1, 0, 0)), "geladene color sollte (1,0,0) sein")
	check_eq(l2.pattern, "streifen", "geladenes pattern sollte 'streifen' sein")
	check_eq(l2.stretch, 1.2, "geladener stretch sollte 1.2 sein")


func test_laden_leer() -> void:
	var l2 := CellLook.from_dict({})

	check_eq(l2.pattern, "keins", "pattern bei leerem Dict sollte 'keins' sein")
	check_eq(l2.stretch, 1.0, "stretch bei leerem Dict sollte 1.0 sein")
	check(l2.color.is_equal_approx(CellLook.DEFAULT_COLOR), "color bei leerem Dict sollte DEFAULT_COLOR sein")


func test_kopie_unabhaengig() -> void:
	look = CellLook.new()
	var c := look.copy()
	c.set_pattern("flecken")
	c.set_stretch(1.4)

	check_eq(look.pattern, "keins", "Original pattern sollte unverändert 'keins' bleiben")
	check_eq(look.stretch, 1.0, "Original stretch sollte unverändert 1.0 bleiben")
