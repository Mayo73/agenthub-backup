extends "res://tests/base_test.gd"

var ghost: GhostLap


func setup() -> void:
	ghost = GhostLap.new()


func test_neu_ist_leer() -> void:
	check(ghost.is_empty(), "is_empty() sollte wahr sein bei leerer Geisterbahn")
	check_eq(ghost.sample_count(), 0, "sample_count() sollte 0 sein")
	check_eq(ghost.duration(), 0.0, "duration() sollte 0.0 sein")


func test_erste_probe_immer() -> void:
	ghost.record(0.0, Vector2(1, 2), 0.5)
	check_eq(ghost.sample_count(), 1, "sample_count() sollte 1 sein")
	check_eq(ghost.positions[0], Vector2(1, 2), "positions[0] sollte Vector2(1, 2) sein")
	check_eq(ghost.headings[0], 0.5, "headings[0] sollte 0.5 sein")
	check(not ghost.is_empty(), "is_empty() sollte falsch sein nach record()")


func test_zu_dichte_probe_wird_ausgelassen() -> void:
	ghost.record(0.0, Vector2.ZERO, 0.0)
	ghost.record(0.02, Vector2(5, 0), 0.0)
	check_eq(ghost.sample_count(), 1, "sample_count() sollte 1 sein (zu dichte Probe ausgelassen)")

	ghost.record(0.05, Vector2(10, 0), 0.0)
	check_eq(ghost.sample_count(), 2, "sample_count() sollte 2 sein nach gültiger Probe")
	check_eq(ghost.positions[1], Vector2(10, 0), "positions[1] sollte Vector2(10, 0) sein")


func test_dauer() -> void:
	ghost.record(0.0, Vector2.ZERO, 0.0)
	ghost.record(0.1, Vector2.ZERO, 0.0)
	ghost.record(0.2, Vector2.ZERO, 0.0)
	check_eq(ghost.duration(), 0.2, "duration() sollte 0.2 sein")
	check_eq(ghost.sample_count(), 3, "sample_count() sollte 3 sein")


func test_position_leer() -> void:
	var ghost_empty := GhostLap.new()
	check_eq(ghost_empty.position_at(1.0), Vector2.ZERO, "position_at bei leerem GhostLap sollte ZERO sein")
	check_eq(ghost_empty.heading_at(1.0), 0.0, "heading_at bei leerem GhostLap sollte 0.0 sein")


func test_position_auf_probe() -> void:
	ghost.record(0.0, Vector2(0, 0), 0.0)
	ghost.record(0.1, Vector2(10, 0), 0.0)
	ghost.record(0.2, Vector2(10, 20), 1.0)
	check_eq(ghost.position_at(0.1), Vector2(10, 0), "position_at(0.1) sollte (10, 0) sein")


func test_position_dazwischen() -> void:
	ghost.record(0.0, Vector2(0, 0), 0.0)
	ghost.record(0.1, Vector2(10, 0), 0.0)
	ghost.record(0.2, Vector2(10, 20), 1.0)
	check(ghost.position_at(0.05).distance_to(Vector2(5, 0)) < 0.01, "position_at(0.05) sollte (5, 0) sein")
	check(ghost.position_at(0.15).distance_to(Vector2(10, 10)) < 0.01, "position_at(0.15) sollte (10, 10) sein")


func test_position_vor_und_nach() -> void:
	ghost.record(0.0, Vector2(0, 0), 0.0)
	ghost.record(0.1, Vector2(10, 0), 0.0)
	ghost.record(0.2, Vector2(10, 20), 1.0)
	check_eq(ghost.position_at(-1.0), Vector2(0, 0), "position_at(-1.0) sollte (0, 0) sein")
	check_eq(ghost.position_at(5.0), Vector2(10, 20), "position_at(5.0) sollte (10, 20) sein")


func test_richtung_dazwischen() -> void:
	ghost.record(0.0, Vector2(0, 0), 0.0)
	ghost.record(0.1, Vector2(10, 0), 0.0)
	ghost.record(0.2, Vector2(10, 20), 1.0)
	check(absf(ghost.heading_at(0.15) - 0.5) < 0.001, "heading_at(0.15) sollte etwa 0.5 sein")
