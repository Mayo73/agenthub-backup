extends "res://tests/base_test.gd"

var motor: CharacterMotor3D


func setup() -> void:
	motor = CharacterMotor3D.new()


func test_richtung() -> void:
	## Vorne bei yaw=0 sollte Vector3(0, 0, -1) sein
	var vorwärts: Vector3 = CharacterMotor3D.wish_direction(Vector2(0, 1), 0.0)
	check(abs(vorwärts.x) < 0.001 and abs(vorwärts.y) < 0.001 and abs(vorwärts.z - (-1.0)) < 0.001,
		"wish_direction(Vector2(0, 1), 0.0) ≈ Vector3(0, 0, -1)")

	## Rechts bei yaw=0 sollte Vector3(1, 0, 0) sein
	var rechts: Vector3 = CharacterMotor3D.wish_direction(Vector2(1, 0), 0.0)
	check(abs(rechts.x - 1.0) < 0.001 and abs(rechts.y) < 0.001 and abs(rechts.z) < 0.001,
		"wish_direction(Vector2(1, 0), 0.0) ≈ Vector3(1, 0, 0)")

	## Diagonal sollte Länge ~1 haben
	var diagonal: Vector3 = CharacterMotor3D.wish_direction(Vector2(1, 1), 0.0)
	check(abs(diagonal.length() - 1.0) < 0.001,
		"wish_direction(Vector2(1, 1), 0.0).length() ≈ 1.0")


func test_beschleunigen() -> void:
	## 1 Sekunde beschleunigen mit 120 Schritten (dt = 1/120)
	for i in range(120):
		motor.step(Vector2(0, 1), 0.0, false, 1.0 / 120.0, true)

	check(abs(motor.horizontal_speed() - 5.0) < 0.5,
		"nach 1s Beschleunigung ist horizontal_speed() ≈ 5.0")
	check(motor.velocity.z < -4.0 and motor.velocity.z < 0,
		"velocity.z < 0 nach Vorwärtsbewegung bei yaw=0")


func test_bremsen() -> void:
	## Danach 60 Schritte ohne Eingabe
	for i in range(60):
		motor.step(Vector2.ZERO, 0.0, false, 1.0 / 120.0, true)

	check(motor.horizontal_speed() < 0.5,
		"nach dem Bremsen ist horizontal_speed() ≈ 0.0")


func test_sprung() -> void:
	## Start am Boden mit velocity.y = 0
	motor.velocity = Vector3.ZERO
	motor.on_floor = true

	## Springen auslösen
	motor.step(Vector2.ZERO, 0.0, true, 1.0 / 120.0, true)
	check_eq(motor.velocity.y, 5.0, "nach Sprung ist velocity.y = 5.0")

	## Nun in der Luft: Schritte zählen bis velocity.y < 0
	motor.on_floor = false
	var schritte: int = 0
	while motor.velocity.y >= 0 and schritte < 200:
		schritte += 1
		motor.step(Vector2.ZERO, 0.0, false, 1.0 / 120.0, false)

	var schritte_pro_sekunde: float = schritte / 120.0
	var erwartete_wert: float = 5.0 / 9.81
	check(abs(schritte_pro_sekunde - erwartete_wert) < 0.02,
		"Anzahl Schritte/120 ≈ %.2f (Toleranz 0.02)" % [erwartete_wert])
