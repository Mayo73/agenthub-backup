extends "res://tests/base_test.gd"

func test_bild() -> void:
	check_eq(WaterBackdrop.TEXTURE != null, true, "TEXTURE darf nicht null sein")
	check_eq(WaterBackdrop.TEXTURE.get_width(), 1024, "BREITE soll 1024 sein")

func test_kacheln() -> void:
	var t := WaterBackdrop.tile_origins(Vector2(1920, 1080), Vector2(100, 50))
	check_eq(t.size(), 9, "Anzahl der Kacheln soll 9 sein")
	check_eq(t[0], Vector2(-924, -974), "erste Ecke soll (-924, -974) sein")
	check_eq(t[8], Vector2(1124, 1074), "neunte Ecke soll (1124, 1074) sein")

func test_ohne_versatz() -> void:
	check_eq(WaterBackdrop.tile_origins(Vector2(1024, 1024), Vector2.ZERO).size(), 4, "Anzahl der Kacheln ohne Versatz soll 4 sein")
