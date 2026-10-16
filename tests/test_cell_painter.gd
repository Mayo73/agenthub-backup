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


func test_schatten() -> void:
	var s := CellPainter.shadow_points(PackedVector2Array([Vector2(0, 0), Vector2(10, 0)]), 10.0, 0.0)
	check(s.size() == 2, "s.size() muss 2 sein")
	check(s[0].is_equal_approx(Vector2(1.2, 1.6)), "s[0] muss bei (1.2, 1.6) liegen")
	check(s[1].is_equal_approx(Vector2(11.2, 1.6)), "s[1] muss bei (11.2, 1.6) liegen")


func test_schatten_gedreht() -> void:
	var s := CellPainter.shadow_points(PackedVector2Array([Vector2(0, 0)]), 10.0, PI / 2.0)
	check(s[0].is_equal_approx(Vector2(1.6, -1.2)), "schatten bei rotation PI/2 muss bei (1.6, -1.2) liegen")
