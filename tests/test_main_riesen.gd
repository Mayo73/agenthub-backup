extends "res://tests/base_test.gd"

var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()


func test_knoten() -> void:
	check(main.world.get_node("DeepGiants") is DeepGiantView, "DeepGiants Knoten existiert und ist DeepGiantView")
	check(main.giant_view.get_parent() == main.world, "giant_view ist Kind von world")


func test_reihenfolge() -> void:
	check(main.backdrop.get_index() == 0, "backdrop hat Index 0")
	check(main.giant_view.get_index() == 1, "giant_view hat Index 1")
	check(main.player.get_index() > main.giant_view.get_index(), "player ist nach giant_view in der Hierarchie")


func test_kamera() -> void:
	check(main.giant_view.camera == main.camera, "giant_view camera zeigt auf main.camera")
