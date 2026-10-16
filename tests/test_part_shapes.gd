extends "res://tests/base_test.gd"


func test_formen() -> void:
	check_eq(PartShapes.shape("kiefer").size(), 4, "Form Kiefer hat 4 Punkte")
	check_eq(PartShapes.shape("geissel").size(), 3, "Form Geißel hat 3 Punkte")
	check_eq(PartShapes.shape("gibtsnicht").size(), 0, "Unbekannte Form ist leer")


func test_farben() -> void:
	check(PartShapes.color_of("stachel").is_equal_approx(Color(0.95, 0.55, 0.2)), "Stachel hat Waffenfarbe")


func test_auge_vorn() -> void:
	var result := PartShapes.placed({"id": "knopfauge", "pos": Vector2(0.4, 0), "angle": 0.0}, 10.0)
	check(result[0].is_equal_approx(Vector2(5.2, 0)), "Augenpunkt vorn stimmt")


func test_stachel_nach_aussen() -> void:
	var result := PartShapes.placed({"id": "stachel", "pos": Vector2(-1, 0), "angle": 0.0}, 10.0)
	check(result[1].is_equal_approx(Vector2(-16, 0)), "Stachel zeigt nach außen")


func test_geissel_haengt_nach_aussen() -> void:
	var result := PartShapes.placed({"id": "geissel", "pos": Vector2(-1, 0), "angle": 0.0}, 10.0)
	check(result[1].is_equal_approx(Vector2(-19, 0)), "Geißel hängt nach außen")
