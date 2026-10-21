extends "res://tests/base_test.gd"

var df: DamageFalloff

func setup() -> void:
	df = DamageFalloff.new()

func test_nah_und_fern() -> void:
	check_eq(df.amount(2.0), 10.0, "amount(2.0) mit Standardwerten")
	check_eq(df.amount(5.0), 10.0, "amount(5.0) mit Standardwerten")
	check_eq(df.amount(30.0), 2.5, "amount(30.0) mit Standardwerten")

func test_mitte() -> void:
	var f: float = df.factor(12.5)
	check(abs(f - 0.625) < 0.0001, "factor(12.5) ist ca. 0.625")

func test_flaeche() -> void:
	var ps: Array[Vector3] = [Vector3.ZERO, Vector3(2, 0, 0), Vector3(0, 5, 0)]
	var result: Array[float] = DamageFalloff.splash(Vector3.ZERO, 4.0, 8.0, ps)
	check_eq(result[0], 8.0, "splash bei distance 0")
	check_eq(result[1], 4.0, "splash bei distance 2")
	check_eq(result[2], 0.0, "splash außerhalb Radius")

func test_ohne_radius() -> void:
	var ps: Array[Vector3] = [Vector3.ZERO, Vector3.ONE]
	var result: Array[float] = DamageFalloff.splash(Vector3.ZERO, 0.0, 8.0, ps)
	check_eq(result[0], 0.0, "splash mit radius=0 ergibt 0")
	check_eq(result[1], 0.0, "splash mit radius=0 ergibt 0")
