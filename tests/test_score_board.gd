extends "res://tests/base_test.gd"

var board: ScoreBoard


func setup() -> void:
	board = ScoreBoard.new()


func teardown() -> void:
	pass


func test_sortiert() -> void:
	check_eq(board.add("a", 100), 1, "erster Eintrag soll Platz 1 haben")
	check_eq(board.add("b", 300), 1, "b mit höherem Score soll auch Platz 1 haben")
	check_eq(board.add("c", 200), 2, "c mit 200 soll Platz 2 haben")

	var names := [board.entries[0]["name"], board.entries[1]["name"], board.entries[2]["name"]]
	check_eq(names, ["b", "c", "a"], "Namen in entries sollen 'b', 'c', 'a' sein")
	check_eq(board.best(), 300, "best() soll 300 zurückgeben")


func test_gleich() -> void:
	board = ScoreBoard.new()
	check_eq(board.add("x", 100), 1, "erster Eintrag mit 100")
	var r: int = board.add("y", 100)
	check_eq(r, 2, "zweiter Aufruf soll Platz 2 zurückgeben")
	check_eq(board.entries[0]["name"], "x", "entries[0][\"name\"] soll 'x' sein (älterer bleibt vorne)")


func test_voll() -> void:
	board = ScoreBoard.new()
	board.max_entries = 3

	var r1: int = board.add("a", 300)
	var r2: int = board.add("b", 200)
	var r3: int = board.add("c", 100)

	check_eq(r1, 1, "a Platz 1")
	check_eq(r2, 2, "b Platz 2")
	check_eq(r3, 3, "c Platz 3")

	check_eq(board.entries.size(), 3, "entries soll Größe 3 haben")

	var r4: int = board.add("d", 50)
	check_eq(r4, 0, "add('d', 50) soll 0 zurückgeben (zu niedrig)")
	check_eq(board.entries.size(), 3, "size soll immer noch 3 sein")

	var r5: int = board.add("e", 150)
	check_eq(r5, 3, "add('e', 150) soll Platz 3 zurückgeben")
	check_eq(board.entries.size(), 3, "size soll nach Kürzen 3 sein")
	check_eq(int(board.entries[2]["score"]), 150, "entries[2][\"score\"] soll 150 sein")


func test_zeilen() -> void:
	board = ScoreBoard.new()
	board.add("a", 100)
	board.add("b", 300)
	board.add("c", 200)

	check_eq(board.lines()[0], "1. b – 300", "lines()[0] soll '1. b – 300' sein")


func test_speichern() -> void:
	var board2: ScoreBoard = ScoreBoard.new()
	board2.add("a", 100)
	board2.add("b", 300)
	board2.add("c", 200)

	var d: Dictionary = JSON.parse_string(JSON.stringify(board2.to_dict()))
	var loaded: ScoreBoard = ScoreBoard.from_dict(d)

	check_eq(loaded.best(), 300, "geladener best() soll 300 sein")
	check_eq(loaded.entries.size(), 3, "geladene entries soll Größe 3 haben")
