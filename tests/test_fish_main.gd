extends "res://tests/base_test.gd"

var fish: Node3D


func setup() -> void:
	fish = load("res://scenes/fish.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(fish)


func teardown() -> void:
	fish.free()


func test_knoten() -> void:
	check(fish is FishMain, "Wurzel ist FishMain")
	check(fish.get_node("World") is Node3D, "Knoten World")
	check(fish.get_node("Camera") is Camera3D, "Knoten Camera")
	check(fish.get_node("Sun") is DirectionalLight3D, "Knoten Sun")
	check(fish.get_node("Water") is WorldEnvironment, "Knoten Water")


func test_wasser() -> void:
	check(fish.water.environment.fog_enabled, "Nebel unter Wasser")
	check_eq(fish.floor_mesh.position.y, -FishWorld.DEPTH, "Boden in der Tiefe")
	check_eq(fish.surface_mesh.position.y, 0.0, "Oberfläche bei y = 0")
	check(fish.floor_mesh.get_parent() == fish.world, "Boden liegt in World")
