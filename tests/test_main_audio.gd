extends "res://tests/base_test.gd"

var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()


func test_audio_da() -> void:
	check(main.audio != null, "audio sollte existieren")
	check(AudioServer.get_bus_index("Musik") >= 0, "Bus 'Musik' sollte existieren")
	check(AudioServer.get_bus_index("Effekte") >= 0, "Bus 'Effekte' sollte existieren")


func test_fressen_klingt() -> void:
	main.food.items.clear()
	main.food.add_item(Diet.PFLANZE, main.player.mouth_point())
	main.feed_player()
	check(main.audio.last_played == "fressen_pflanze", "sollte 'fressen_pflanze' abgespielt haben")


func test_wachsen_klingt() -> void:
	main.food.items.clear()
	main.progress.eat(9)
	main.food.add_item(Diet.PFLANZE, main.player.mouth_point())
	main.feed_player()
	check(main.audio.last_played == "wachsen", "sollte 'wachsen' abgespielt haben")


func test_tod_klingt() -> void:
	main.player_health.damage(1000.0)
	main.check_death()
	check(main.audio.last_played == "tod", "sollte 'tod' abgespielt haben")
