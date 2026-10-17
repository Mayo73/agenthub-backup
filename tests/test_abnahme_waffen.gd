extends "res://tests/base_test.gd"

const P := "user://test_abnahme_waffen.json"
var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	main.save_path = P
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()
	var dir := FileAccess.open(P, FileAccess.READ)
	if dir != null:
		dir.close()
		DirAccess.remove_absolute(ProjectSettings.globalize_path(P))


func _put(cell: AiCell, pos: Vector2) -> void:
	cell.motion.position = pos
	cell.position = pos


func test_stachel() -> void:
	main.start_scene("stachel")
	var cell: AiCell = main.ai_cells[0]
	var tips := WeaponRules.spike_tips(main.player.motion.position, main.player.motion.heading, main.player.radius, main.player.build)
	check_eq(tips.size(), 1, "tips.size() ist 1")
	_put(cell, tips[0] + Vector2(cell.radius * 0.5, 0))
	var vorher: float = cell.health.hp
	main.resolve_weapons(0.016)
	check(cell.health.hp < vorher, "cell.health.hp < vorher")


func test_stachel_nur_vorn() -> void:
	main.start_scene("stachel")
	var cell: AiCell = main.ai_cells[0]
	_put(cell, Vector2(-main.player.radius - cell.radius * 0.9, 0))
	var vorher: float = cell.health.hp
	main.resolve_weapons(0.016)
	check_eq(cell.health.hp, vorher, "cell.health.hp ist vorher")


func test_gift() -> void:
	main.start_scene("gift")
	main.player.motion.velocity = Vector2(100, 0)
	main.resolve_weapons(0.016)
	check_eq(main.poison.clouds.size(), 1, "main.poison.clouds.size() ist 1")
	var cell: AiCell = main.ai_cells[0]
	_put(cell, main.poison.clouds[0]["pos"])
	var vorher: float = cell.health.hp
	main.resolve_weapons(0.5)
	check(cell.health.hp < vorher, "cell.health.hp < vorher")


func test_elektro() -> void:
	main.start_scene("elektro")
	var cell: AiCell = main.ai_cells[0]
	_put(cell, Vector2(main.player.radius + cell.radius, 0))
	var vorher: float = cell.health.hp
	main.resolve_weapons(0.016)
	check_eq(cell.health.hp, vorher - ElectricOrgan.DAMAGE, "cell.health.hp ist vorher - ElectricOrgan.DAMAGE")
	check(not main.electric.is_ready(), "main.electric.is_ready() falsch")


func test_elektro_zu_weit() -> void:
	main.start_scene("elektro")
	var cell: AiCell = main.ai_cells[0]
	_put(cell, Vector2(main.player.radius * 3.0 + cell.radius, 0))
	var vorher: float = cell.health.hp
	main.resolve_weapons(0.016)
	check_eq(cell.health.hp, vorher, "cell.health.hp ist vorher")
	check(main.electric.is_ready(), "main.electric.is_ready() wahr")
