extends "res://tests/base_test.gd"

const PATH := "user://test_stats_spielstand.json"
var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)
	main.save_path = PATH


func teardown() -> void:
	main.free()
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))


func test_fressen_zaehlt() -> void:
	main.food.items.clear()
	main.food.add_item(Diet.PFLANZE, main.player.mouth_point())
	main.feed_player()
	check_eq(main.stats.food_eaten, 1, "main.stats.food_eaten ist 1")


func test_wachsen_merkt_ernaehrung() -> void:
	main.food.items.clear()
	main.progress.eat(9)
	main.food.add_item(Diet.PFLANZE, main.player.mouth_point())
	main.feed_player()
	check_eq(main.stats.diet_history.size(), 1, "main.stats.diet_history.size() ist 1")


func test_tod_zaehlt() -> void:
	main.player_health.damage(1000.0)
	main.check_death()
	check_eq(main.stats.deaths, 1, "main.stats.deaths ist 1")


func test_neue_partie() -> void:
	main.stats.deaths = 3
	main.start_new(Diet.PFLANZENFRESSER)
	check_eq(main.stats.deaths, 0, "main.stats.deaths ist 0")


func test_gespeichert() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	main.stats.food_eaten = 7
	check(main.save_now(), "main.save_now() wahr")
	main.stats = RunStats.new()
	check(main.load_saved(), "main.load_saved() wahr")
	check_eq(main.stats.food_eaten, 7, "main.stats.food_eaten ist 7")
