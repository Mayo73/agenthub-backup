extends "res://tests/base_test.gd"

var car: Node2D

func setup() -> void:
	Controls.setup()
	car = load("res://scenes/car.tscn").instantiate()

func teardown() -> void:
	Input.action_release("gas")
	car.free()
	car = null

func test_eingabe_aktiv() -> void:
	Input.action_press("gas")
	car._physics_process(0.1)
	check_eq(car.physics.throttle, 1.0, "throttle soll 1.0 sein wenn input_enabled true ist")

func test_eingabe_gesperrt() -> void:
	car.input_enabled = false
	Input.action_press("gas")
	car._physics_process(0.1)
	check_eq(car.physics.throttle, 0.0, "throttle soll 0.0 sein wenn input_enabled false ist")
	check(not car.physics.handbrake, "handbrake soll false sein wenn input_enabled false ist")

func test_neustart_taste() -> void:
	check(InputMap.has_action("neustart"), "Action neustart muss existieren")
