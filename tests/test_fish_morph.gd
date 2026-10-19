extends "res://tests/base_test.gd"

var morph: FishMorph

func setup() -> void:
	morph = FishMorph.new()

func teardown() -> void:
	pass

func test_anfang() -> void:
	morph.start()
	check_eq(morph.stretch(), 1.0, "stretch() sollte 1.0 sein")
	check_eq(morph.tail(), 0.0, "tail() sollte 0.0 sein")
	check_eq(morph.fade(), 0.0, "fade() sollte 0.0 sein")

func test_mitte() -> void:
	morph.start()
	morph.tick(1.25)
	check_eq(morph.morph(), 0.5, "morph() sollte 0.5 bei 1.25s sein")
	check_eq(morph.fade(), 0.0, "fade() sollte noch 0.0 sein")

func test_ende() -> void:
	morph.start()
	morph.tick(2.5)
	check_eq(morph.stretch(), 2.2, "stretch() sollte 2.2 nach 2.5s sein")
	check_eq(morph.tail(), 0.9, "tail() sollte 0.9 nach 2.5s sein")
	morph.tick(0.4)
	check_eq(morph.fade(), 0.5, "fade() sollte 0.5 nach weiteren 0.4s sein")
	morph.tick(0.4)
	check(morph.is_done(), "is_done() sollte true sein")
	check(not morph.running, "running sollte false sein")

func test_ohne_start() -> void:
	morph.tick(1.0)
	check_eq(morph.time, 0.0, "time sollte 0.0 bleiben ohne start()")
