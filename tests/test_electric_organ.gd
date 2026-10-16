extends "res://tests/base_test.gd"

var e: ElectricOrgan

func setup() -> void:
	e = ElectricOrgan.new()


func test_bereit() -> void:
	check(e.is_ready(), "am Anfang bereit")
	e.fire()
	check(not e.is_ready(), "nach fire nicht bereit")
	check_eq(e.flash, 0.2, "flash ist 0.2 nach fire")


func test_nachladen() -> void:
	e.fire()
	e.tick(1.0)
	check(not e.is_ready(), "nach tick(1.0) noch nicht bereit")
	e.tick(0.5)
	check(e.is_ready(), "nach tick(0.5) bereit")
	check_eq(e.flash, 0.0, "flash ist 0.0 nachdem er verloschen ist")


func test_reichweite() -> void:
	check(ElectricOrgan.in_range(Vector2.ZERO, 10.0, Vector2(25, 0), 10.0), "in Reichweite bei (25, 0)")
	check(not ElectricOrgan.in_range(Vector2.ZERO, 10.0, Vector2(27, 0), 10.0), "nicht in Reichweite bei (27, 0)")
