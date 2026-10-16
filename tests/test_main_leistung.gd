extends "res://tests/base_test.gd"

var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()


func test_ohne_schalter() -> void:
	check_eq(main.benchmark, null, "main.benchmark ist ohne --benchmark null")


func test_start() -> void:
	main.start_benchmark()
	check(main.benchmark != null, "nach start_benchmark ist main.benchmark gesetzt")
	check(not main.autosave, "nach start_benchmark ist autosave falsch")
	check(not main.in_menu, "nach start_benchmark ist in_menu falsch")
	check_eq(int(main.benchmark.ai_counter.call()), main.ai_cells.size(), "ai_counter gibt ai_cells.size() zurück")


func test_ki_zellen() -> void:
	main.start_benchmark()
	main.spawn_ai()
	check(main.benchmark.ai_counter.call() >= 30, "nach spawn_ai sind mindestens 30 KI-Zellen")
