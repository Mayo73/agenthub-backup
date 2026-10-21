extends "res://tests/base_test.gd"


func test_landen() -> void:
	var blocks_result := OneWayPlatform.blocks(5.0, 9.9, 10.2, 10.0)
	check(blocks_result, "blocks(5.0, 9.9, 10.2, 10.0) soll wahr sein")

	var land_result := OneWayPlatform.land(10.2, 10.0)
	check_eq(land_result, 10.0, "land(10.2, 10.0) soll 10.0 sein")


func test_von_unten() -> void:
	var block_1 := OneWayPlatform.blocks(-5.0, 9.9, 10.2, 10.0)
	check(not block_1, "blocks(-5.0, 9.9, 10.2, 10.0) soll falsch sein (vel_y negativ)")

	var block_2 := OneWayPlatform.blocks(5.0, 10.5, 11.0, 10.0)
	check(not block_2, "blocks(5.0, 10.5, 11.0, 10.0) soll falsch sein (prev_foot_y > top_y)")


func test_durchfallen() -> void:
	var drop_result := OneWayPlatform.blocks(5.0, 9.9, 10.2, 10.0, true)
	check(not drop_result, "blocks(5.0, 9.9, 10.2, 10.0, true) soll falsch sein (drop)")


func test_breite() -> void:
	var span_1 := OneWayPlatform.in_span(3.0, 0.0, 3.0)
	check(span_1, "in_span(3.0, 0.0, 3.0) soll wahr sein (obere Grenze)")

	var span_2 := OneWayPlatform.in_span(-0.1, 0.0, 3.0)
	check(not span_2, "in_span(-0.1, 0.0, 3.0) soll falsch sein (unterhalb x_min)")
