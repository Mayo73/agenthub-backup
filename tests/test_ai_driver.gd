extends "res://tests/base_test.gd"

var driver: AiDriver
var path: TrackPath
var physics: CarPhysics


func setup() -> void:
	driver = AiDriver.new()
	path = TrackPath.new(PackedVector2Array([Vector2(0, 0), Vector2(2000, 0), Vector2(2000, 2000), Vector2(0, 2000)]), 280.0)
	physics = CarPhysics.new()
	physics.position = Vector2(100, 0)


func test_geradeaus() -> void:
	physics.heading = 0.0
	driver.drive(physics, path)
	check(absf(physics.steer) < 0.01, "Lenkung muss bei gerader Ausrichtung nahe null sein")
	check_eq(physics.throttle, 0.9, "Gas sollte skill-Wert sein")
	check_eq(physics.brake, 0.0, "Bremse sollte deaktiviert sein")


func test_lenkt_links() -> void:
	physics.heading = PI / 2.0
	driver.drive(physics, path)
	check_eq(physics.steer, -1.0, "Lenkung muss voll nach links ausschlagen")


func test_lenkt_rechts() -> void:
	physics.heading = -PI / 2.0
	driver.drive(physics, path)
	check_eq(physics.steer, 1.0, "Lenkung muss voll nach rechts ausschlagen")


func test_bremst_wenn_zu_schnell() -> void:
	physics.heading = 0.0
	physics.velocity = Vector2(900, 0)
	driver.drive(physics, path)
	check_eq(physics.throttle, 0.0, "Gas muss bei zu hoher Geschwindigkeit aus sein")
	check_eq(physics.brake, 0.5, "Bremse muss aktiviert werden")
