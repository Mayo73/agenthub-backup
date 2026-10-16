extends "res://tests/base_test.gd"


func test_raute() -> void:
	var d := PickupView.diamond(Vector2(10, 0), 0.0)
	check_eq(d.size(), 4, "Raute hat 4 Eckpunkte")
	check_eq(d[0], Vector2(19, 0), "erster Eckpunkt ist (19, 0)")
	check_eq(d[3], Vector2(10, -9), "letzter Eckpunkt ist (10, -9)")


func test_pulsieren() -> void:
	var d := PickupView.diamond(Vector2.ZERO, PI / 8)
	check_eq(d[0].x, 10.8, "pulsierende Größe bei t=PI/8")


func test_zeit() -> void:
	var v := PickupView.new()
	v._process(0.5)
	check_eq(v.time, 0.5, "time wird um delta erhöht")
	v.free()
