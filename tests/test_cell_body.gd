extends "res://tests/base_test.gd"

var look: CellLook


func setup() -> void:
	look = CellLook.new()


func test_anzahl() -> void:
	check_eq(CellBody.wobble(look, 10.0, 0.0).size(), 32, "default points ist 32")
	check_eq(CellBody.wobble(look, 10.0, 0.0, 8).size(), 8, "custom points ist 8")


func test_erster_punkt() -> void:
	var result := CellBody.wobble(look, 10.0, 0.0)
	check(result[0].is_equal_approx(Vector2(10, 0)), "erster punkt bei t=0 sollte (10, 0) sein")


func test_wogen_begrenzt() -> void:
	for t in [0.0, 0.7, 1.9]:
		var result := CellBody.wobble(look, 10.0, t)
		for p in result:
			check(p.length() <= 10.0 * 1.04 + 0.001, "punkt bei t=%s darf nicht zu weit außen sein: %s" % [t, p])
			check(p.length() >= 10.0 * 0.96 - 0.001, "punkt bei t=%s darf nicht zu weit innen sein: %s" % [t, p])


func test_bewegt_sich() -> void:
	var at_0 := CellBody.wobble(look, 10.0, 0.0)[3]
	var at_05 := CellBody.wobble(look, 10.0, 0.5)[3]
	check(!at_0.is_equal_approx(at_05), "punkt sollte sich bei zeitänderung bewegen")


func test_halbe_groesse() -> void:
	look.set_stretch(1.25)
	var result := CellBody.half_size(look, 10.0)
	check(result.is_equal_approx(Vector2(13.0, 8.32)), "halbe größe bei stretch 1.25")


func test_uvs() -> void:
	var uv := CellBody.uvs(PackedVector2Array([Vector2(10, 0), Vector2.ZERO, Vector2(0, -5)]), Vector2(10, 5))
	check(uv[0].is_equal_approx(Vector2(1.0, 0.5)), "uv[0] sollte (1.0, 0.5) sein")
	check(uv[1].is_equal_approx(Vector2(0.5, 0.5)), "uv[1] sollte (0.5, 0.5) sein")
	check(uv[2].is_equal_approx(Vector2(0.5, 0.0)), "uv[2] sollte (0.5, 0.0) sein")
