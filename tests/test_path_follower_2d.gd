extends "res://tests/base_test.gd"

var path: Array[Vector2] = [Vector2(0, 0), Vector2(2, 0), Vector2(2, 2)]


func _near(a: Vector2, b: Vector2, tol: float = 0.01) -> bool:
	return absf(a.x - b.x) <= tol and absf(a.y - b.y) <= tol


func test_einmal() -> void:
	var f := PathFollower2D.new(path, 1.0, "once")
	check(_near(f.step(1.0), Vector2(1, 0)), "step(1) bei (1, 0)")
	check(_near(f.step(2.0), Vector2(2, 1)), "step(2) bei (2, 1)")
	check(_near(f.step(5.0), Vector2(2, 2)), "step(5) am Ende")
	check(f.finished, "finished")


func test_schleife() -> void:
	var f := PathFollower2D.new(path, 1.0, "loop")
	check(_near(f.step(4.0), Vector2(2, 2)), "step(4) bei (2, 2)")
	check(_near(f.step(2.0), Vector2(0.586, 0.586)), "step(2) auf dem Rückweg zum Start")
	check(not f.finished, "nicht fertig")


func test_pendel() -> void:
	var f := PathFollower2D.new(path, 1.0, "pingpong")
	check(_near(f.step(5.0), Vector2(2, 1)), "step(5) wieder zurück bei (2, 1)")
	check_eq(f.direction, -1)


func test_einzelpunkt() -> void:
	var single: Array[Vector2] = [Vector2(3, 3)]
	var f := PathFollower2D.new(single, 1.0, "once")
	check(f.finished, "finished bei einem Punkt")
	check(_near(f.step(1.0), Vector2(3, 3)), "bleibt stehen")
