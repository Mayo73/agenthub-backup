extends "res://tests/base_test.gd"

var car: Node2D

func setup() -> void:
	car = load("res://scenes/car.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(car)


func teardown() -> void:
	car.free()
	car = null


func test_motor_vorhanden() -> void:
	check(car.get_node("Engine") is AudioStreamPlayer2D, "Engine ist ein AudioStreamPlayer2D")
	check(car.engine_player.stream is AudioStreamWAV, "engine_player.stream ist AudioStreamWAV")
	check(absf(car.engine_player.pitch_scale - 0.6) < 0.001, "pitch_scale初始值正确")


func test_motor_folgt_tempo() -> void:
	car.physics.velocity = Vector2(car.physics.max_speed * 0.5, 0.0)
	car.physics.throttle = 1.0
	car.update_sound()
	check(absf(car.engine_player.pitch_scale - 1.3) < 0.001, "pitch_scale bei halbem Tempo")
	check(absf(car.engine_player.volume_db - (-6.0)) < 0.001, "volume_db bei Vollgas")
