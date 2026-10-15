extends "res://tests/base_test.gd"

var a: CarPhysics
var b: CarPhysics

func setup() -> void:
	a = CarPhysics.new()
	b = CarPhysics.new()


func test_weit_weg() -> void:
	a.position = Vector2(0, 0)
	b.position = Vector2(100, 0)
	var result := CarCollision.resolve(a, b, 20.0)
	check(not result, "sollte false zurückgeben, wenn Autos weit genug entfernt sind")
	check_eq(b.position, Vector2(100, 0), "Position von b sollte unverändert sein")


func test_auseinanderschieben() -> void:
	a.position = Vector2(0, 0)
	b.position = Vector2(30, 0)
	var result := CarCollision.resolve(a, b, 20.0)
	check(result, "sollte true zurückgeben, wenn Autos kollidieren")
	check_eq(a.position, Vector2(-5, 0), "Position von a sollte nach links verschoben werden")
	check_eq(b.position, Vector2(35, 0), "Position von b sollte nach rechts verschoben werden")


func test_abprallen() -> void:
	a.position = Vector2(0, 0)
	b.position = Vector2(30, 0)
	a.velocity = Vector2(100, 0)
	b.velocity = Vector2(-100, 0)
	CarCollision.resolve(a, b, 20.0)
	check(absf(a.velocity.x - (-30.0)) < 0.01, "velocity von a sollte Vector2(-30, 0) sein")
	check(absf(b.velocity.x - 30.0) < 0.01, "velocity von b sollte Vector2(30, 0) sein")


func test_auseinanderfahren_kein_abprall() -> void:
	a.position = Vector2(0, 0)
	b.position = Vector2(30, 0)
	a.velocity = Vector2(-50, 0)
	b.velocity = Vector2(50, 0)
	CarCollision.resolve(a, b, 20.0)
	check_eq(a.velocity, Vector2(-50, 0), "velocity von a sollte unverändert bleiben")
	check_eq(b.velocity, Vector2(50, 0), "velocity von b sollte unverändert bleiben")
