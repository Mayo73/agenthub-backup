extends "res://tests/base_test.gd"

var main: Node2D
var cell: AiCell


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)
	cell = AiCell.new()
	cell.setup("schnapper", Vector2(300, 0))


func teardown() -> void:
	cell.free()
	main.free()


func test_normal() -> void:
	main.settings.set_difficulty(1)
	var expected = CombatRules.bite_damage(cell.damage, cell.radius, main.player.radius)
	check_eq(main.enemy_bite_damage(cell), expected, "Schaden bei Normal")


func test_leicht() -> void:
	main.settings.set_difficulty(0)
	var expected = 0.6 * CombatRules.bite_damage(cell.damage, cell.radius, main.player.radius)
	check_eq(main.enemy_bite_damage(cell), expected, "Schaden bei Leicht")


func test_schwer() -> void:
	main.settings.set_difficulty(2)
	var expected = 1.5 * CombatRules.bite_damage(cell.damage, cell.radius, main.player.radius)
	check_eq(main.enemy_bite_damage(cell), expected, "Schaden bei Schwer")


func test_aufruf() -> void:
	var content = FileAccess.get_file_as_string("res://scripts/main.gd")
	check(content.contains("player_health.damage(enemy_bite_damage(cell))"), "Aufruf von enemy_bite_damage in resolve_combat")
