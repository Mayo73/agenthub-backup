extends "res://tests/base_test.gd"

var body: Body2D


func setup() -> void:
	body = Body2D.new()


func teardown() -> void:
	pass


func test_faellt() -> void:
	## Körper bei (0, 0), run(0.5, 100.0) → position.y ungefähr 1.226 (Toleranz 0.05), on_floor falsch
	body.position = Vector2.ZERO
	body.velocity = Vector2.ZERO
	body.run(0.5, 100.0)

	var expected_y: float = 1.226
	var tolerance: float = 0.05

	check(absf(body.position.y - expected_y) < tolerance, "position.y ist ungefähr %.3f (war %.3f)" % [expected_y, body.position.y])
	check(not body.on_floor, "on_floor soll falsch sein")


func test_landet() -> void:
	## Körper bei (0, 0), run(3.0, 10.0) → position.y 10.0, on_floor wahr, velocity.y 0.0
	body.position = Vector2.ZERO
	body.velocity = Vector2.ZERO
	body.run(3.0, 10.0)

	check_eq(body.position.y, 10.0, "position.y soll 10.0 sein")
	check(body.on_floor, "on_floor soll wahr sein")
	check_eq(body.velocity.y, 0.0, "velocity.y soll 0.0 sein")


func test_impuls() -> void:
	## mass = 2.0, apply_impulse(Vector2(4, 0)) → velocity.x 2.0
	body.mass = 2.0
	body.velocity = Vector2.ZERO

	body.apply_impulse(Vector2(4.0, 0.0))

	check_eq(body.velocity.x, 2.0, "velocity.x soll 2.0 sein (4 / 2)")


func test_reibung() -> void:
	## auf dem Boden (position = Vector2(0, 10)), velocity = Vector2(3, 0), friction = 0.5, run(2.0, 10.0) → velocity.x 0.0
	body.position = Vector2(0.0, 10.0)
	body.velocity = Vector2(3.0, 0.0)
	body.friction = 0.5
	body.on_floor = true

	body.run(2.0, 10.0)

	check_eq(body.velocity.x, 0.0, "velocity.x soll nach Reibung 0.0 sein")


func test_reibung_ohne() -> void:
	## mit friction = 0.0 bleibt velocity.x 3.0
	body.position = Vector2(0.0, 10.0)
	body.velocity = Vector2(3.0, 0.0)
	body.friction = 0.0
	body.on_floor = true

	body.run(2.0, 10.0)

	check_eq(body.velocity.x, 3.0, "velocity.x soll ohne Reibung 3.0 bleiben")


func test_rueckprall() -> void:
	## bounce = 0.5, Start (0, 0), so lange step bis on_floor wahr (höchstens 1000 Schritte) → velocity.y < 0
	body.bounce = 0.5
	body.position = Vector2.ZERO
	body.velocity = Vector2.ZERO

	var stepped: bool = false
	for i in range(1000):
		body.step(1.0 / 120.0, 10.0)
		if body.on_floor:
			stepped = true
			break

	check(stepped, "Körper muss innerhalb von 1000 Schritten den Boden erreichen")
	check(body.velocity.y < 0.0, "velocity.y soll nach Rückprall negativ sein (war %.3f)" % body.velocity.y)


func test_rueckprall_kein() -> void:
	## mit bounce = 0.0 ist velocity.y dann 0.0
	body.bounce = 0.0
	body.position = Vector2.ZERO
	body.velocity = Vector2.ZERO

	for i in range(1000):
		body.step(1.0 / 120.0, 10.0)
		if body.on_floor:
			break

	check_eq(body.velocity.y, 0.0, "velocity.y soll bei bounce=0.0 sein 0.0")
