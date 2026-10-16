extends "res://tests/base_test.gd"

var m: FpsMeter

func setup() -> void:
	m = FpsMeter.new()


func test_leer() -> void:
	check_eq(m.average_fps(), 0.0, "average_fps ohne Messung ist 0.0")
	check_eq(m.min_fps(), 0.0, "min_fps ohne Messung ist 0.0")


func test_gleichmaessig() -> void:
	for _i in range(60):
		m.add_frame(1.0 / 60.0)
	check_eq(m.frames, 60, "frames nach 60 Frames ist 60")
	check_eq(m.elapsed, 1.0, "elapsed nach 60 Frames ist 1.0")
	check_eq(m.average_fps(), 60.0, "average_fps ist 60.0")
	check_eq(m.min_fps(), 60.0, "min_fps ist 60.0")


func test_minimum() -> void:
	m.add_frame(1.0 / 60.0)
	m.add_frame(1.0 / 30.0)
	check_eq(m.min_fps(), 30.0, "min_fps ist 30.0 (langsamster Frame)")
	check_eq(m.average_fps(), 40.0, "average_fps ist 40.0")


func test_null_uebergehen() -> void:
	m.add_frame(0.0)
	m.add_frame(-1.0)
	check_eq(m.frames, 0, "frames bleibt 0 bei delta <= 0")


func test_zuruecksetzen() -> void:
	m.add_frame(0.1)
	m.reset()
	check_eq(m.frames, 0, "frames nach reset ist 0")
	check_eq(m.min_fps(), 0.0, "min_fps nach reset ist 0.0")
