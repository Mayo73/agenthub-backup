extends "res://tests/base_test.gd"

var spring: Spring2D
var a: Body2D
var b: Body2D


func setup() -> void:
	a = Body2D.new()
	b = Body2D.new()
	spring = Spring2D.new(a, b, 1.0)


func test_ruhe() -> void:
	a.position = Vector2.ZERO
	b.position = Vector2(1.0, 0.0)
	check_eq(spring.force_on_a(), Vector2.ZERO, "Federkraft bei Ruhelänge muss null sein")


func test_zieht() -> void:
	a.position = Vector2.ZERO
	b.position = Vector2(3.0, 0.0)
	var force := spring.force_on_a()
	check(force.x > 0.0, "Kraft muss in positive x-Richtung ziehen")
	check_eq(force.y, 0.0, "Kraft y-Komponente bei horizontaler Feder ist null")


func test_drueckt() -> void:
	a.position = Vector2.ZERO
	b.position = Vector2(0.5, 0.0)
	var force := spring.force_on_a()
	check(force.x < 0.0, "Kraft muss in negative x-Richtung drücken")


func test_pendelt_ein() -> void:
	a = Body2D.new()
	a.position = Vector2(0.0, 2.0)
	spring = Spring2D.new(a, null, 1.0)
	spring.anchor = Vector2.ZERO

	var steps: int = roundi(10.0 * 120.0)
	for i in range(steps):
		spring.apply(1.0 / 120.0)
		a.position += a.velocity * (1.0 / 120.0)

	var len: float = spring.length()
	check(abs(len - 1.0) < 0.05, "Pendel sollte bei Ruhezustand Länge 1.0 haben, ist aber %.05f" % len)


func test_impuls_beidseitig() -> void:
	a = Body2D.new()
	b = Body2D.new()
	a.mass = 1.0
	b.mass = 1.0
	a.position = Vector2.ZERO
	b.position = Vector2(3.0, 0.0)
	spring = Spring2D.new(a, b, 1.0)

	spring.apply(0.1)

	check(a.velocity.x > 0.0, "Körper a muss positive x-Geschwindigkeit bekommen")
	check(b.velocity.x < 0.0, "Körper b muss negative x-Geschwindigkeit bekommen")
	var diff: float = abs(abs(a.velocity.x) - abs(b.velocity.x))
	check(diff < 0.01, "Beträge der Geschwindigkeiten müssen ungefähr gleich sein (Differenz %.4f)" % diff)
