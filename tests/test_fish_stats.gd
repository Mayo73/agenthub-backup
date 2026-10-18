extends "res://tests/base_test.gd"

var stats: FishStats


func setup() -> void:
	stats = FishStats.new()


func test_anfang() -> void:
	check_eq(stats.total_eaten(), 0, "total_eaten() ist 0")
	check_eq(stats.deaths, 0, "deaths ist 0")
	check_eq(stats.max_depth, 0.0, "max_depth ist 0.0")


func test_fressen() -> void:
	stats.record_eaten("silberling")
	stats.record_eaten("silberling")
	stats.record_eaten("grasfisch")
	check_eq(stats.eaten["silberling"], 2, "eaten[\"silberling\"] ist 2")
	check_eq(stats.total_eaten(), 3, "total_eaten() ist 3")


func test_tiefe() -> void:
	stats.record_depth(20.0)
	stats.record_depth(42.4)
	stats.record_depth(10.0)
	check_eq(stats.max_depth, 42.4, "max_depth ist 42.4")


func test_hin_und_zurueck() -> void:
	stats.record_eaten("silberling")
	stats.record_eaten("silberling")
	stats.record_death()
	stats.record_depth(33.0)

	var cloned = FishStats.from_dict(stats.to_dict())

	check_eq(cloned.total_eaten(), stats.total_eaten(), "total_eaten() gleich nach Clone")
	check_eq(cloned.deaths, stats.deaths, "deaths gleich nach Clone")
	check_eq(cloned.max_depth, stats.max_depth, "max_depth gleich nach Clone")


func test_kaputte_daten() -> void:
	var bad = FishStats.from_dict({"eaten": 5, "deaths": -3, "max_depth": -1.0})

	check_eq(bad.total_eaten(), 0, "total_eaten() ist 0 bei kaputten Daten")
	check_eq(bad.deaths, 0, "deaths ist 0 bei kaputten Daten")
	check_eq(bad.max_depth, 0.0, "max_depth ist 0.0 bei kaputten Daten")


func test_zusammenfassung() -> void:
	stats.record_eaten("silberling")
	stats.record_eaten("grasfisch")
	stats.record_eaten("silberling")
	stats.record_death()
	stats.max_depth = 41.6

	check_eq(stats.summary(), "Gefressen: 3 · Tode: 1 · Tiefste Stelle: 42 m", "summary() ist korrekt")
