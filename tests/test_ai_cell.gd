extends "res://tests/base_test.gd"

var cell: AiCell

func setup() -> void:
	cell = AiCell.new()


func teardown() -> void:
	cell.free()


func test_werte_der_art() -> void:
	cell.setup("schnapper", Vector2(50, 0))
	check_eq(cell.radius, 18.0, "radius")
	check_eq(cell.diet, Diet.FLEISCHFRESSER, "diet")
	check_eq(cell.health.max_hp, 40.0, "max_hp")
	check_eq(cell.motion.max_speed, 150.0, "max_speed")
	check_eq(cell.position, Vector2(50, 0), "position")
	check_eq(cell.damage, 15.0, "damage")


func test_jagen_und_schwimmen() -> void:
	cell.setup("schnapper", Vector2(50, 0))
	cell.think([{"position": Vector2(150, 0), "radius": 12.0, "diet": Diet.PFLANZENFRESSER}], null)
	check_eq(cell.wish, Vector2.RIGHT, "wish")
	check_eq(cell.brain.state, AiBrain.JAGEN, "state")
	cell.drive(0.1)
	check(cell.position.x > 50.0, "position moved right")


func test_info() -> void:
	cell.setup("blasenling", Vector2(5, 5))
	check_eq(cell.info()["radius"], 12.0, "info radius")
	check_eq(cell.info()["diet"], Diet.PFLANZENFRESSER, "info diet")


func test_maul() -> void:
	cell.setup("blasenling", Vector2.ZERO)
	check_eq(cell.mouth_point(), Vector2(12, 0), "mouth point")
