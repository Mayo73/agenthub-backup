extends "res://tests/base_test.gd"


func test_ring() -> void:
	var p := PartPickups.new(4)
	for _i in 20:
		p.spawn_around(Vector2(100, 0), 50.0, 80.0)
	check_eq(p.positions.size(), 20, "positions.size() ist 20")
	var center := Vector2(100, 0)
	for pos in p.positions:
		var dist := center.distance_to(pos)
		check(dist >= 49.99 && dist <= 80.01, "Abstand zu (100, 0) liegt zwischen 49.99 und 80.01: " + str(dist))


func test_reproduzierbar() -> void:
	var p1 := PartPickups.new(4)
	var p2 := PartPickups.new(4)
	var pos1 := p1.spawn_around(Vector2.ZERO, 50.0, 80.0)
	var pos2 := p2.spawn_around(Vector2.ZERO, 50.0, 80.0)
	check(pos1 == pos2, "die beiden Rückgabewerte sind gleich")


func test_beruehren() -> void:
	var p := PartPickups.new(4)
	p.positions.append(Vector2(20, 0))
	p.positions.append(Vector2(100, 0))
	check_eq(p.take_touching(Vector2.ZERO, 12.0), 1, "take_touching ist 1")
	check_eq(p.positions.size(), 1, "positions.size() ist 1")
	check_eq(p.take_touching(Vector2.ZERO, 12.0), 0, "erneut take_touching ist 0")


func test_weit_weg() -> void:
	var p := PartPickups.new(4)
	p.positions.append(Vector2(20, 0))
	p.positions.append(Vector2(100, 0))
	check_eq(p.remove_far(Vector2.ZERO, 50.0), 1, "remove_far ist 1")
	check_eq(p.positions[0], Vector2(20, 0), "positions[0] ist (20, 0)")
