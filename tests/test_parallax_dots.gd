extends "res://tests/base_test.gd"


func test_ebenen() -> void:
	var dots := ParallaxDots.new()
	check_eq(dots.layers.size(), 3, "layers.size() ist 3")
	for i in dots.layers.size():
		check_eq(dots.layers[i].size(), 60, "Ebene %d hat 60 Punkte" % i)
		for p in dots.layers[i]:
			check(p.x >= 0 and p.x < 1024, "x-Koordinate von Punkt in Ebene %d ist >= 0 und < 1024" % i)
			check(p.y >= 0 and p.y < 1024, "y-Koordinate von Punkt in Ebene %d ist >= 0 und < 1024" % i)


func test_reproduzierbar() -> void:
	var dots1 := ParallaxDots.new(10, 4)
	var dots2 := ParallaxDots.new(10, 4)
	check_eq(dots1.layers[1][3], dots2.layers[1][3], "layers[1][3] ist bei beiden gleich")


func test_verschiebung() -> void:
	var offset1 := ParallaxDots.layer_offset(Vector2(100, 0), 0.5)
	check_eq(offset1, Vector2(974, 0), "layer_offset(Vector2(100, 0), 0.5) ist (974, 0)")

	var offset2 := ParallaxDots.layer_offset(Vector2(-2058, 0), 1.0)
	check_eq(offset2, Vector2(10, 0), "layer_offset(Vector2(-2058, 0), 1.0) ist (10, 0)")

	var offset3 := ParallaxDots.layer_offset(Vector2.ZERO, 0.75)
	check_eq(offset3, Vector2.ZERO, "layer_offset(Vector2.ZERO, 0.75) ist (0, 0)")
