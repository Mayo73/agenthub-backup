extends "res://tests/base_test.gd"

var sounds: Node
var race: RaceState


func setup() -> void:
	sounds = preload("res://scripts/race_sounds.gd").new()
	(Engine.get_main_loop() as SceneTree).root.add_child(sounds)
	race = RaceState.new()


func teardown() -> void:
	sounds.free()
	sounds = null


func test_countdown() -> void:
	sounds.update(race)
	check_eq(sounds.beeps, 1, "erster Countdown-Ton (3)")

	race.update(0.5)
	race.update(0.5)
	sounds.update(race)
	check_eq(sounds.beeps, 2, "zweiter Countdown-Ton (2)")

	race.update(0.5)
	race.update(0.5)
	sounds.update(race)
	check_eq(sounds.beeps, 3, "dritter Countdown-Ton (1)")

	sounds.reset()
	race.update(0.5)
	race.update(0.5)
	race.update(0.5)
	sounds.update(race)
	check_eq(sounds.gos, 1, "ein Los!-Ton")


func test_neustart() -> void:
	sounds.update(race)
	sounds.reset()
	check_eq(sounds.last_text, "", "reset setzt last_text auf leer")

	sounds.update(race)
	check_eq(sounds.beeps, 2, "Reset ermöglicht nächsten Countdown-Ton von vorn")


func test_knoten() -> void:
	check(sounds.get_node("Beep") is AudioStreamPlayer, "Beep ist AudioStreamPlayer")
	check(sounds.get_node("Go") is AudioStreamPlayer, "Go ist AudioStreamPlayer")
