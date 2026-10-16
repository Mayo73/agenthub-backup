extends "res://tests/base_test.gd"

var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()


func _add_ai(id: String, pos: Vector2, heading: float) -> AiCell:
	var cell := AiCell.new()
	cell.setup(id, pos)
	cell.motion.heading = heading
	main.world.add_child(cell)
	main.ai_cells.append(cell)
	return cell


func test_ki_blitzt() -> void:
	main.player.diet = Diet.FLEISCHFRESSER
	var cell := _add_ai("schnapper", Vector2(30, 0), 0.0)
	main.resolve_combat()
	check(main.player.diet == Diet.FLEISCHFRESSER, "diet ist FLEISCHFRESSER")
	check(cell.flash.is_active(), "KI-Zelle blitzt nach Biss")


func test_spieler_blitzt() -> void:
	_add_ai("schnapper", Vector2(30, 0), PI)
	main.resolve_combat()
	check(main.player.flash.is_active(), "Spielerzelle blitzt nach Biss von KI")


func test_klingt_ab() -> void:
	main.player.flash.trigger()
	main.player.drive(1.0, Vector2.ZERO)
	check(not main.player.flash.is_active(), "Flash klingt nach drive() ab")


func test_ki_ruhig() -> void:
	var cell := _add_ai("weidezelle", Vector2(300, 0), 0.0)
	main.resolve_combat()
	check(not cell.flash.is_active(), "KI-Zelle blitzt nicht bei zu großem Abstand")
