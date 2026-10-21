extends "res://tests/base_test.gd"

var path: GridPath


func setup() -> void:
	path = GridPath.new(Vector2i(5, 5))


func test_gerade() -> void:
	var result: Array = path.find_path(Vector2i(0, 0), Vector2i(2, 0))
	check_eq(result, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)], "Weg gerade")


func test_umweg() -> void:
	path.set_blocked(Vector2i(1, 0), true)
	path.set_blocked(Vector2i(1, 1), true)
	path.set_blocked(Vector2i(1, 2), true)
	path.set_blocked(Vector2i(1, 3), true)

	var result: Array = path.find_path(Vector2i(0, 0), Vector2i(2, 0))
	check(result.size() == 11, "Weg hat 11 Zellen")
	check(result[0] == Vector2i(0, 0), "weg beginnt bei (0,0)")
	check(result[result.size() - 1] == Vector2i(2, 0), "weg endet bei (2,0)")
	var found: bool = false
	for cell in result:
		if cell == Vector2i(1, 4):
			found = true
			break
	check(found, "Weg enthält Zelle (1,4)")


func test_unerreichbar() -> void:
	path.set_blocked(Vector2i(1, 0), true)
	path.set_blocked(Vector2i(1, 1), true)
	path.set_blocked(Vector2i(1, 2), true)
	path.set_blocked(Vector2i(1, 3), true)
	path.set_blocked(Vector2i(1, 4), true)

	var result: Array = path.find_path(Vector2i(0, 0), Vector2i(2, 0))
	check_eq(result, [], "Weg ist leer wenn Ziel blockiert")


func test_ziel_gesperrt() -> void:
	path.set_blocked(Vector2i(3, 3), true)
	var result: Array = path.find_path(Vector2i(0, 0), Vector2i(3, 3))
	check_eq(result, [], "Ziel gesperrt ergibt leerer Weg")

	path.set_blocked(Vector2i(3, 3), false)
	result = path.find_path(Vector2i(0, 0), Vector2i(3, 3))
	check(not result.is_empty(), "Nach Freigabe ist Weg nicht leer")
