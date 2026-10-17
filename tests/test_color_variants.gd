extends "res://tests/base_test.gd"

func test_unveraendert() -> void:
	var c := Color.from_hsv(0.5, 0.6, 0.5)
	check_eq(ColorVariants.vary(c, 0.0), c, "Zelle bei t=0 bleibt unverändert")


func test_heller() -> void:
	var v := ColorVariants.vary(Color.from_hsv(0.5, 0.6, 0.5), 1.0)
	check_eq(v.h, 0.53, "Farbton bei t=1: 0.53")
	check_eq(v.v, 0.58, "Helligkeit bei t=1: 0.58")
	check_eq(v.s, 0.6, "Sättigung bei t=1: 0.6")


func test_dunkler() -> void:
	var v := ColorVariants.vary(Color.from_hsv(0.5, 0.6, 0.5), -1.0)
	check_eq(v.h, 0.47, "Farbton bei t=-1: 0.47")
	check_eq(v.v, 0.42, "Helligkeit bei t=-1: 0.42")


func test_begrenzt() -> void:
	check_eq(ColorVariants.vary(Color.from_hsv(0.5, 0.6, 0.5), 5.0),
		ColorVariants.vary(Color.from_hsv(0.5, 0.6, 0.5), 1.0), "t=5 wird auf t=1 begrenzt")


func test_farbkreis() -> void:
	check_eq(ColorVariants.vary(Color.from_hsv(0.99, 0.6, 0.5), 1.0).h, 0.02,
		"Farbton umkreist bei 0.99 + 0.03 zu 0.02")


func test_durchsichtig() -> void:
	check_eq(ColorVariants.vary(Color(0.2, 0.6, 0.4, 0.5), 1.0).a, 0.5, "Alpha bleibt bei 0.5")


func test_lage() -> void:
	check_eq(ColorVariants.seed_for(Vector2.ZERO), 0.0, "seed_for((0,0)) = 0.0")
	check_eq(ColorVariants.seed_for(Vector2(100, 0)), sin(1.3), "seed_for((100,0)) = sin(1.3)")
	check(ColorVariants.seed_for(Vector2(37, -90)) >= -1.0, "seed_for((37,-90)) >= -1.0")
