extends "res://tests/base_test.gd"

var ghost: Node2D

func setup() -> void:
	ghost = preload("res://scripts/ghost_car.gd").new()


func teardown() -> void:
	ghost.free()


func test_ohne_aufnahme_unsichtbar() -> void:
	check(not ghost.visible, "initial unsichtbar")
	ghost.show_at(null, 1.0)
	check(not ghost.visible, "nach show_at(null, 1.0) unsichtbar")
	var empty_lap := GhostLap.new()
	ghost.show_at(empty_lap, 1.0)
	check(not ghost.visible, "nach show_at(leere GhostLap, 1.0) unsichtbar")


func test_folgt_aufnahme() -> void:
	var lap := GhostLap.new()
	lap.record(0.0, Vector2(0, 0), 0.0)
	lap.record(0.1, Vector2(10, 0), 0.0)
	ghost.show_at(lap, 0.05)
	check(ghost.visible, "nach show_at mit gültiger Aufnahme sichtbar")
	check(ghost.position.distance_to(Vector2(5, 0)) < 0.01, "position korrekt bei midway")
	check(ghost.rotation == 0.0, "rotation ist 0.0 bei gerader Strecke")
