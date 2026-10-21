extends "res://tests/base_test.gd"

var motor: PlatformerMotor
const DT := 1.0 / 120.0


func setup() -> void:
	motor = PlatformerMotor.new()


func teardown() -> void:
	pass  ## RefCounted-Objekte nicht manuell freigeben in Godot


func test_beschleunigen() -> void:
	## 120 Schritte nach rechts → velocity.x sollte ca. 5.0 sein
	for i in 120:
		motor.step(1, DT, true)
	check(abs(motor.velocity.x - 5.0) < 0.5, "velocity.x erreicht ca. 5.0 nach Beschleunigen")

	## Danach 120 Schritte ohne Eingabe → velocity.x sollte ca. 0 sein
	for i in 120:
		motor.step(0, DT, true)
	check(abs(motor.velocity.x) < 0.5, "velocity.x läuft auf 0 aus wenn keine Eingabe")


func test_springen() -> void:
	motor.press_jump()
	motor.step(0, DT, true)
	check(abs(motor.velocity.y - (-6.0)) < 0.5, "velocity.y ist ca. -6 beim Springen")


func test_nachsprung() -> void:
	## Neuer Motor für diesen Test
	motor = PlatformerMotor.new()

	## Ein Schritt am Boden
	motor.step(0, DT, true)
	check(motor.on_floor, "startet am Boden")

	## 6 Schritte in der Luft (ca. 0.05s < coyote_time von 0.1s)
	for i in 6:
		motor.step(0, DT, false)

	## Jetzt Sprungknopf drücken und Schritt → sollte springen
	motor.press_jump()
	motor.step(0, DT, false)
	check(abs(motor.velocity.y - (-6.0)) < 0.5, "Nachsprung: velocity.y ist ca. -6")

	## Neuer Motor mit 24 Schritten in der Luft statt 6 → kein Sprung möglich (24 * DT ≈ 0.2s > coyote_time)
	motor = PlatformerMotor.new()
	motor.step(0, DT, true)
	for i in 24:
		motor.step(0, DT, false)
	motor.press_jump()
	motor.step(0, DT, false)
	check(motor.velocity.y > 0, "Nach 24 Schritten in der Luft (coyote_time überschritten): kein Sprung, velocity.y > 0")


func test_gemerkt() -> void:
	## In der Luft Sprung drücken
	motor = PlatformerMotor.new()
	motor.step(0, DT, false)
	motor.press_jump()

	## 6 Schritte in der Luft, dann Bodenkontakt → sollte springen (buffer_time = 0.1s, 6 * DT ≈ 0.05s)
	for i in 6:
		motor.step(0, DT, false)
	motor.step(0, DT, true)
	check(abs(motor.velocity.y - (-6.0)) < 0.5, "Gemerkt: velocity.y ist ca. -6 nach Landung innerhalb buffer_time")


func test_schwerkraft() -> void:
	## 120 Schritte in der Luft (jeder Schritt erhöht y um gravity * DT)
	for i in 120:
		motor.step(0, DT, false)
	## Nach 120 Schritten: velocity.y ≈ gravity * dt * schritte = 9.81 * (1/120) * 120 = 9.81
	check(abs(motor.velocity.y - 9.81) < 0.5, "velocity.y erreicht ca. 9.81 nach Schwerkraft")
