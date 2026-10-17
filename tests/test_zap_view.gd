extends "res://tests/base_test.gd"

var v: ZapView


func setup() -> void:
	v = ZapView.new()


func teardown() -> void:
	v.free()


func test_zwei_blitze() -> void:
	var ziele: Array[Vector2] = [Vector2(100, 0), Vector2(0, 100)]
	v.show_zaps(Vector2.ZERO, ziele)
	check_eq(v.lines.size(), 2, "es sollen zwei Blitze sein")
	check(v.lines[0][0] == Vector2.ZERO, "erster Blitz beginnt bei Vector2.ZERO")
	check(v.lines[0][6] == Vector2(100, 0), "erster Blitz endet bei Vector2(100, 0)")
	check(v.lines[1][6] == Vector2(0, 100), "zweiter Blitz endet bei Vector2(0, 100)")
	check(v.is_zap_visible(), "Blitze sind sichtbar")


func test_verblasst() -> void:
	var ziele: Array[Vector2] = [Vector2(50, 0)]
	v.show_zaps(Vector2.ZERO, ziele)
	check(v.is_zap_visible(), "nach 0.1s noch sichtbar")
	v.tick(0.1)
	check(v.is_zap_visible(), "noch sichtbar nach tick(0.1)")
	v.tick(0.2)
	check(not v.is_zap_visible(), "nicht mehr sichtbar nach tick(0.2)")
	check_eq(v.lines.size(), 0, "lines ist leer")


func test_anfangs_leer() -> void:
	check(not v.is_zap_visible(), "am Anfang sind keine Blitze sichtbar")
