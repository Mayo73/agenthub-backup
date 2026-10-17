extends "res://tests/base_test.gd"

const P := "user://test_main_ki_waffen.json"
var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	main.save_path = P
	(Engine.get_main_loop() as SceneTree).root.add_child(main)
	main.start_new(Diet.PFLANZENFRESSER)
	for cell in main.ai_cells.duplicate():
		main.remove_ai(cell)
	main.settings.difficulty = Difficulty.NORMAL
	main.player_health.invulnerable = 0.0


func teardown() -> void:
	main.free()
	if FileAccess.file_exists(P):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(P))


func _add(id: String, offset: Vector2) -> AiCell:
	var cell := AiCell.new()
	var pos: Vector2 = main.player.motion.position + offset
	cell.setup(id, pos)
	cell.motion.heading = 0.0
	main.world.add_child(cell)
	main.ai_cells.append(cell)
	return cell


func test_stachelkugel_sticht() -> void:
	_add("stachelkugel", Vector2(-30, 0))
	var vorher: float = main.player_health.hp
	main.resolve_ai_weapons(0.016)
	check_eq(vorher - main.player_health.hp, WeaponRules.SPIKE_DAMAGE, "Stachelkugel verursacht SPIKE_DAMAGE")


func test_schwer() -> void:
	main.settings.difficulty = 2
	_add("stachelkugel", Vector2(-30, 0))
	var vorher: float = main.player_health.hp
	main.resolve_ai_weapons(0.016)
	check_eq(vorher - main.player_health.hp, WeaponRules.SPIKE_DAMAGE * 1.5, "Schwerer Schwierigkeitsgrad multipliziert mit 1.5")


func test_ohne_stacheln() -> void:
	_add("blasenling", Vector2(-30, 0))
	var vorher: float = main.player_health.hp
	main.resolve_ai_weapons(0.016)
	check_eq(main.player_health.hp, vorher, "Blasenling verursacht keinen Schaden")


func test_weit_weg() -> void:
	_add("stachelkugel", Vector2(-200, 0))
	var vorher: float = main.player_health.hp
	main.resolve_ai_weapons(0.016)
	check_eq(main.player_health.hp, vorher, "Zu weit entfernt verursacht keinen Schaden")


func test_im_ablauf() -> void:
	check(FileAccess.get_file_as_string("res://scripts/main.gd").contains("resolve_ai_weapons(delta)"), "main.gd enthält resolve_ai_weapons(delta)")
