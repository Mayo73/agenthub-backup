extends "res://tests/base_test.gd"


func test_ohne_luft() -> void:
	var w := Wind.new()
	var result := w.acceleration(Vector3(10, 0, 0))
	check_eq(result, Vector3.ZERO, "kein Luftwiderstand bei drag=0")


func test_bremst() -> void:
	var w := Wind.new(0.5)
	var result := w.acceleration(Vector3(10, 0, 0))
	var expected := Vector3(-5, 0, 0)
	check_eq(result, expected, "Bremsung bei drag=0.5")


func test_wind_schiebt() -> void:
	var w := Wind.new(0.5, Vector3(4, 0, 0))
	var result := w.acceleration(Vector3.ZERO)
	var expected := Vector3(2, 0, 0)
	check_eq(result, expected, "Wind drückt bei v=0")


func test_endgeschwindigkeit() -> void:
	var w := Wind.new(0.5)
	var v := Vector3.ZERO
	var dt: float = 1.0 / 120.0
	var gravity: Vector3 = Vector3(0, -9.81, 0)

	for _i in range(20 * 120):
		v = w.step(v, dt) + gravity * dt

	var speed := -v.y
	var terminal := w.terminal_velocity(9.81)
	check(abs(speed - terminal) < 0.1, "Endgeschwindigkeit: %.2f ≈ %.2f" % [speed, terminal])


func test_2d() -> void:
	var w := Wind.new(1.0, Vector3(0, 2, 0))
	var result := w.acceleration_2d(Vector2(0, 2))
	check_eq(result, Vector2.ZERO, "Keine Beschleunigung bei Relativgeschwindigkeit 0 in 2D")


func test_speichern() -> void:
	var original := Wind.new(0.3, Vector3(1, 2, 3))
	var as_dict := original.to_dict()
	var restored := Wind.from_dict(as_dict)

	check_eq(restored.drag, 0.3, "drag korrekt gespeichert")
	check_eq(restored.wind, Vector3(1, 2, 3), "wind korrekt gespeichert")
