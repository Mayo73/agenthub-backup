extends "res://tests/base_test.gd"

var lap_timer: LapTimer

func setup() -> void:
	lap_timer = LapTimer.new(1000.0)


func test_runde_wird_gezaehlt() -> void:
	var p := 0.0
	p = 100.0
	lap_timer.update(1.0, p)
	p = 300.0
	lap_timer.update(1.0, p)
	p = 500.0
	lap_timer.update(1.0, p)
	p = 700.0
	lap_timer.update(1.0, p)
	p = 900.0
	lap_timer.update(1.0, p)
	p = 50.0
	lap_timer.update(1.0, p)

	check_eq(lap_timer.lap, 1, "Runde sollte 1 sein")
	check_eq(lap_timer.last_lap_time, 6.0, "last_lap_time sollte 6.0 sein")
	check_eq(lap_timer.current_time, 0.0, "current_time sollte 0.0 sein")


func test_ohne_haelfte_keine_runde() -> void:
	var p := 0.0
	p = 900.0
	lap_timer.update(1.0, p)
	p = 50.0
	lap_timer.update(1.0, p)

	check_eq(lap_timer.lap, 0, "Runde sollte 0 sein")


func test_rueckwaerts_ueber_ziel_zaehlt_nicht() -> void:
	var p := 0.0
	p = 50.0
	lap_timer.update(1.0, p)
	p = 950.0
	lap_timer.update(1.0, p)
	p = 500.0
	lap_timer.update(1.0, p)
	p = 50.0
	lap_timer.update(1.0, p)

	check_eq(lap_timer.lap, 0, "Runde sollte 0 sein")


func test_bestzeit() -> void:
	var p := 0.0
	p = 100.0
	lap_timer.update(1.0, p)
	p = 500.0
	lap_timer.update(1.0, p)
	p = 900.0
	lap_timer.update(1.0, p)
	p = 50.0
	lap_timer.update(1.0, p)

	check_eq(lap_timer.lap, 1, "Runde 1 sollte 1 sein")
	check_eq(lap_timer.last_lap_time, 4.0, "last_lap_time nach Runde 1 sollte 4.0 sein")

	p = 500.0
	lap_timer.update(1.0, p)
	p = 900.0
	lap_timer.update(1.0, p)
	p = 50.0
	lap_timer.update(1.0, p)

	check_eq(lap_timer.best_lap_time, 3.0, "best_lap_time sollte 3.0 sein")
	check_eq(lap_timer.last_lap_time, 3.0, "last_lap_time sollte 3.0 sein")


func test_zeitformat() -> void:
	check_eq(LapTimer.format_time(75.25), "1:15.25", "Format für 75.25s")
	check_eq(LapTimer.format_time(5.0), "0:05.00", "Format für 5.0s")
	check_eq(LapTimer.format_time(-1.0), "–", "Format für negativen Wert")


func test_reset_vergisst_haelfte() -> void:
	lap_timer.update(1.0, 500.0)
	lap_timer.reset()
	lap_timer.update(1.0, 900.0)
	lap_timer.update(1.0, 50.0)
	check_eq(lap_timer.lap, 0, "nach reset() muss die Hälfte erneut passiert werden")
