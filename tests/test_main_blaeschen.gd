extends "res://tests/base_test.gd"

var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()


func test_view() -> void:
	check_eq(main.bubble_view.get_parent(), main.world, "bubble_view ist Kind von world")
	check_eq(main.bubble_view.trail, main.bubbles, "bubble_view.trail zeigt auf bubbles")


func test_schnell() -> void:
	main.player.motion.velocity = Vector2(200, 0)
	main.update_bubbles(0.1)
	check_eq(main.bubbles.bubbles.size(), 1, "ein Bläschen erzeugt bei schnellem Schwimmen")
	var pos := main.bubbles.bubbles[0]["pos"] as Vector2
	check(pos.x < main.player.motion.position.x, "Bläschen entsteht hinter der Zelle")


func test_langsam() -> void:
	main.player.motion.velocity = Vector2.ZERO
	main.update_bubbles(0.1)
	check_eq(main.bubbles.bubbles.size(), 0, "keine Bläschen bei langsamer Bewegung")


func test_takt() -> void:
	main.player.motion.velocity = Vector2(200, 0)
	main.update_bubbles(0.1)
	main.update_bubbles(0.01)
	check_eq(main.bubbles.bubbles.size(), 1, "nur ein Bläschen pro Taktintervall")
