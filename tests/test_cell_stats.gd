extends "res://tests/base_test.gd"

var b: CellBuild

func setup() -> void:
	b = CellBuild.starter(Diet.PFLANZENFRESSER)


func test_startwerte() -> void:
	check_eq(CellStats.max_speed(b, 0), 220.0, "max_speed bei stage 0")
	check_eq(CellStats.max_speed(b, 2), 280.0, "max_speed bei stage 2")
	check_eq(CellStats.turn_rate(b), 6.0, "turn_rate ohne Bonus")
	check_eq(CellStats.diet(b), Diet.PFLANZENFRESSER, "diet bei Pflanzenfresser")


func test_geisseln_abnehmend() -> void:
	b.add_part("geissel", Vector2(-1, 0))
	check_eq(CellStats.max_speed(b, 0), 280.0, "eine Geißel")
	b.add_part("geissel", Vector2(-1, 0))
	check_eq(CellStats.max_speed(b, 0), 310.0, "zweite Geißel")
	b.add_part("geissel", Vector2(-1, 0))
	check_eq(CellStats.max_speed(b, 0), 325.0, "dritte Geißel")


func test_wimpern() -> void:
	b.add_part("wimpern", Vector2(-1, 0))
	check_eq(CellStats.max_speed(b, 0), 240.0, "max_speed mit Wimpern")
	check_eq(CellStats.turn_rate(b), 9.0, "turn_rate mit Wimpern")


func test_duesen() -> void:
	b.add_part("duese", Vector2(-1, 0))
	b.add_part("duese", Vector2(-1, 0))
	check_eq(CellStats.max_speed(b, 0), 370.0, "max_speed mit zwei Düsen")
	check_eq(CellStats.turn_rate(b), 4.5, "turn_rate mit zwei Düsen")


func test_ernaehrung() -> void:
	check_eq(CellStats.diet(CellBuild.starter(Diet.FLEISCHFRESSER)), Diet.FLEISCHFRESSER, "Fleischfresser Start")
	b.add_part("kiefer", Vector2(0.9, 0.3))
	check_eq(CellStats.diet(b), Diet.ALLESFRESSER, "nach Kiefer Allesfresser")
	check_eq(CellStats.diet(CellBuild.new()), "", "ohne Maul leer")
