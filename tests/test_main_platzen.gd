extends "res://tests/base_test.gd"

var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()


func test_in_der_welt() -> void:
	check(main.burst_view.get_parent() == main.world, "burst_view ist Kind von world")


func test_ki_platzt() -> void:
	var cell := AiCell.new()
	cell.setup("blasenling", Vector2(300, 0))
	main.world.add_child(cell)
	main.ai_cells.append(cell)
	cell.health.damage(1000.0)
	main.resolve_combat()
	check_eq(main.burst_view.bursts.bursts.size(), 1, "genau ein Burst")
	check((main.burst_view.bursts.bursts[0]["pos"] as Vector2).is_equal_approx(Vector2(300, 0)), "Position korrekt")


func test_spieler_platzt() -> void:
	main.player_health.damage(1000.0)
	main.check_death()
	check_eq(main.burst_view.bursts.bursts.size(), 1, "genau ein Burst")
