extends "res://tests/base_test.gd"

var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()


func test_knoten() -> void:
	check(main.world.get_node("PoisonClouds") is PoisonCloudView, "PoisonClouds Knoten existiert und ist PoisonCloudView")
	check(main.poison_view.get_parent() == main.world, "poison_view ist Kind von world")


func test_quelle() -> void:
	check(main.poison_view.sources.has(main.poison), "poison ist in sources enthalten")


func test_wolke_sichtbar() -> void:
	main.poison.emit(Vector2(10, 0))
	check_eq(main.poison_view.cloud_count(), 1, "genau eine Wolke nach emit")
