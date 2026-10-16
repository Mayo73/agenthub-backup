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


func test_aussehen_der_art() -> void:
	var c := AiCell.new()
	c.setup("schnapper", Vector2.ZERO)
	check_eq(c.look.pattern, "streifen", "pattern")
	check_eq(c.look.stretch, 1.3, "stretch")
	check_eq(c.behavior, "jaeger", "behavior")
	c.free()


func test_stacheln() -> void:
	var c := AiCell.new()
	c.setup("stachelkugel", Vector2.ZERO)
	check_eq(c.spike_shapes().size(), 8, "spike count")
	var spikes := c.spike_shapes()
	check(spikes[0][1].is_equal_approx(Vector2(c.radius * 1.5, 0)), "first spike tip")
	c.free()


func test_zeit() -> void:
	var c := AiCell.new()
	c.setup("blasenling", Vector2.ZERO)
	c.drive(0.5)
	check_eq(c.time, 0.5, "time")
	c.free()
