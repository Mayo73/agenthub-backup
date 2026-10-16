extends "res://tests/base_test.gd"

var cell: PlayerCell


func setup() -> void:
	cell = PlayerCell.new()


func teardown() -> void:
	cell.free()


func test_schwimmen() -> void:
	cell.drive(0.1, Vector2.RIGHT)
	check_eq(cell.position.x, 6.0, "position x nach Rechtsbewegung")
	check_eq(cell.rotation, 0.0, "rotation nach Rechtsbewegung")


func test_drehen() -> void:
	cell.drive(0.1, Vector2.UP)
	check_eq(cell.rotation, -0.6, "rotation nach Bewegung nach oben")
