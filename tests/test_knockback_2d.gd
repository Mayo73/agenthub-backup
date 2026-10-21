extends "res://tests/base_test.gd"


func setup() -> void:
	pass


func teardown() -> void:
	pass


func test_richtung() -> void:
	var knockback := Knockback2D.new(10.0)
	knockback.hit(Vector2(0, 0), Vector2(3, 4), 10.0)
	check(knockback.velocity.is_equal_approx(Vector2(6, 8)), "velocity nach hit auf (3,4)")


func test_abklingen() -> void:
	var knockback := Knockback2D.new(10.0)
	knockback.hit(Vector2(0, 0), Vector2(3, 4), 10.0)

	var offset1 := knockback.step(0.5)
	check(offset1.is_equal_approx(Vector2(3, 4)), "offset nach step(0.5)")
	check(knockback.velocity.is_equal_approx(Vector2(3, 4)), "velocity nach step(0.5)")

	var offset2 := knockback.step(1.0)
	check(offset2.is_equal_approx(Vector2(3, 4)), "offset nach step(1.0)")
	check(not knockback.active(), "active() soll nach Abklingen false sein")


func test_gleiche_position() -> void:
	var knockback := Knockback2D.new(10.0)
	knockback.hit(Vector2(1, 1), Vector2(1, 1), 5.0)
	check(knockback.velocity.is_equal_approx(Vector2(0, -5)), "velocity bei gleicher Position")
