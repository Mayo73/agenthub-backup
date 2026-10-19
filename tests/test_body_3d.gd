extends "res://tests/base_test.gd"

var body: Body3D


func setup() -> void:
	body = Body3D.new()


func teardown() -> void:
	pass  # RefCounted wird automatisch freigegeben


func test_faellt() -> void:
	## Start (0, 10, 0), run(0.5, -100.0) → position.y ungefähr 8.77 (Toleranz 0.05)
	body.position = Vector3(0.0, 10.0, 0.0)
	body.velocity = Vector3.ZERO
	body.run(0.5, -100.0)
	var expected: float = 8.77
	check(absf(body.position.y - expected) < 0.05, "position.y nach 0.5s fallend etwa %.2f" % expected)


func test_landet() -> void:
	## Start (0, 5, 0), run(3.0, 0.0) → position.y 0.0, on_floor wahr
	body.position = Vector3(0.0, 5.0, 0.0)
	body.velocity = Vector3.ZERO
	body.run(3.0, 0.0)
	check_eq(body.position.y, 0.0, "position.y nach Landung 0.0")
	check(body.on_floor == true, "on_floor nach Landung wahr")


func test_impuls() -> void:
	## mass = 4.0, apply_impulse(Vector3(0, 0, 8)) → velocity.z 2.0
	body.mass = 4.0
	body.apply_impulse(Vector3(0.0, 0.0, 8.0))
	check_eq(body.velocity.z, 2.0, "velocity.z nach Impuls (8/4=2) 2.0")


func test_reibung() -> void:
	## auf dem Boden, velocity = Vector3(3, 0, 4), run(2.0, 0.0) → velocity.x und velocity.z 0.0
	body.position = Vector3(0.0, 0.0, 0.0)
	body.velocity = Vector3(3.0, 0.0, 4.0)
	body.on_floor = true
	body.friction = 0.5
	body.run(2.0, 0.0)
	check_eq(body.velocity.x, 0.0, "velocity.x nach Reibung 0.0")
	check_eq(body.velocity.z, 0.0, "velocity.z nach Reibung 0.0")


func test_rueckprall() -> void:
	## bounce = 0.5, Start (0, 2, 0), schrittweise bis on_floor (höchstens 1000 Schritte) → velocity.y > 0
	body.position = Vector3(0.0, 2.0, 0.0)
	body.velocity = Vector3.ZERO
	body.bounce = 0.5
	var steps: int = 0
	while not body.on_floor and steps < 1000:
		body.step(1.0 / 120.0, 0.0)
		steps += 1
	check(body.on_floor == true, "nach maximal 1000 Schritten on_floor wahr")
	check(body.velocity.y > 0.0, "velocity.y nach Rückprall positiv")
