extends "res://tests/base_test.gd"

var m: FishMotion

func setup() -> void:
	m = FishMotion.new()


func test_vorne() -> void:
	check(FishMotion.forward_of(0.0, 0.0).is_equal_approx(Vector3(0, 0, -1)), "forward bei yaw=0, pitch=0 zeigt nach -z")
	check(FishMotion.forward_of(PI / 2.0, 0.0).is_equal_approx(Vector3(-1, 0, 0)), "forward bei yaw=PI/2 zeigt nach -x")
	check(FishMotion.forward_of(0.0, PI / 2.0).is_equal_approx(Vector3(0, 1, 0)), "forward bei pitch=PI/2 zeigt nach +y")


func test_start() -> void:
	check_eq(m.position, FishWorld.START, "position startet bei FishWorld.START")
	check_eq(m.depth(), 20.0, "depth() gibt 20.0 zurück")
	check_eq(m.speed(), 0.0, "speed() gibt 0.0 zurück")


func test_schub() -> void:
	m.step(1.0, 0.0, 0.0, 0.1)
	check_eq(m.velocity.z, -0.85, "velocity.z nach Schritt mit vollem Schub ist -0.85")
	check_eq(m.position.z, -0.085, "position.z nach Schritt ist -0.085")
	check_eq(m.position.y, -20.0, "position.y bleibt -20.0")


func test_hoechsttempo() -> void:
	for i in 200:
		m.step(1.0, 0.0, 0.0, 0.1)
	check(m.speed() <= m.max_speed + 0.001, "speed überschreitet max_speed nicht")
	check(m.speed() > 5.0, "speed ist nach 200 Schritten größer als 5.0")


func test_drehen() -> void:
	m.step(0.0, 1.0, 0.0, 0.5)
	check_eq(m.yaw, 0.9, "yaw nach Schritt mit turn=1 ist 0.9")
	m = FishMotion.new()
	m.step(0.0, -1.0, 0.0, 0.5)
	check_eq(m.yaw, -0.9, "yaw nach Schritt mit turn=-1 ist -0.9")


func test_auftauchen() -> void:
	for i in 10:
		m.step(0.0, 0.0, 1.0, 0.1)
	check_eq(m.pitch, FishMotion.MAX_PITCH, "pitch nach 10 Schritten mit climb=1 ist MAX_PITCH")
	m = FishMotion.new()
	for i in 50:
		m.step(1.0, 0.0, 1.0, 0.1)
	check(m.position.y > -15.0, "position.y nach 50 Schritten mit climb=1 ist > -15.0")


func test_abtauchen() -> void:
	m = FishMotion.new()
	for i in 60:
		m.step(1.0, 0.0, -1.0, 0.1)
	check(m.position.y < -25.0, "position.y nach 60 Schritten mit climb=-1 ist < -25.0")


func test_ausrichten() -> void:
	m = FishMotion.new()
	m.pitch = 1.0
	m.step(0.0, 0.0, 0.0, 0.5)
	check_eq(m.pitch, 0.3, "pitch nach Schritt mit climb=0 ist 0.3")


func test_oberflaeche() -> void:
	m = FishMotion.new()
	m.position = Vector3(0, -1, 0)
	m.velocity = Vector3(0, 5, 0)
	m.drag = 0.0
	m.step(0.0, 0.0, 0.0, 1.0)
	check_eq(m.position.y, -0.5, "position.y an Oberfläche ist -0.5")
	check_eq(m.velocity.y, 0.0, "velocity.y an Oberfläche wird auf 0 gesetzt")


func test_boden() -> void:
	m = FishMotion.new()
	m.position = Vector3(0, -59, 0)
	m.velocity = Vector3(0, -6, 0)
	m.drag = 0.0
	m.step(0.0, 0.0, 0.0, 1.0)
	check_eq(m.position.y, -FishWorld.DEPTH + 0.5, "position.y am Boden ist DEPTH-0.5")
	check_eq(m.velocity.y, 0.0, "velocity.y am Boden wird auf 0 gesetzt")
