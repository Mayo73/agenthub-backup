extends "res://tests/base_test.gd"

func test_scroll() -> void:
	check_eq(Parallax.scroll(Vector2(100.0, 50.0), Vector2(0.5, 0.0)), Vector2(-50.0, 0.0), "scroll mit factor (0.5, 0.0)")
	check_eq(Parallax.scroll(Vector2(100.0, 50.0), Vector2(1.0, 1.0)), Vector2(-100.0, -50.0), "scroll mit factor (1.0, 1.0)")


func test_wrap() -> void:
	check_eq(Parallax.wrap(-30.0, 100.0), 70.0, "wrap negative position")
	check_eq(Parallax.wrap(250.0, 100.0), 50.0, "wrap position größer als width")
	check_eq(Parallax.wrap(5.0, 0.0), 5.0, "wrap bei width 0")


func test_kacheln() -> void:
	check_eq(Parallax.tiles_needed(1280.0, 512.0), 4, "tiles_needed mit view_width=1280, tile_width=512")
	check_eq(Parallax.tiles_needed(1024.0, 512.0), 3, "tiles_needed mit view_width=1024, tile_width=512")
	check_eq(Parallax.tiles_needed(100.0, 0.0), 0, "tiles_needed bei tile_width 0")
