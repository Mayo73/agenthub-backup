extends "res://tests/base_test.gd"

func test_textur() -> void:
	check(CellPainter.TEXTURE != null, "TEXTUR muss geladen sein")
	check(CellPainter.TEXTURE.get_width() >= 500, "TEXTUR mindestens 500 Pixel breit")


func test_musterfarbe() -> void:
	var l := CellLook.new()
	l.color = Color(1, 1, 1)
	check(CellPainter.pattern_color(l).is_equal_approx(Color(0.65, 0.65, 0.65, 0.8)), "Musterfarbe bei Weiß")


func test_randfarbe() -> void:
	var l := CellLook.new()
	l.color = Color(0, 0, 0)
	check(CellPainter.rim_color(l).is_equal_approx(Color(0.35, 0.35, 0.35, 0.9)), "Randfarbe bei Schwarz")


func test_randbreite() -> void:
	check_eq(CellPainter.rim_width(5.0), 1.0, "Randbreite bei Radius 5.0")
	check_eq(CellPainter.rim_width(50.0), 4.0, "Randbreite bei Radius 50.0")
