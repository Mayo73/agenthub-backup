extends "res://tests/base_test.gd"


func test_rauch_nur_beim_driften() -> void:
	var car: Node2D = load("res://scenes/car.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(car)
	var smoke := car.get_node("Smoke") as CPUParticles2D
	check(smoke != null, "Car/Smoke existiert")
	check(not smoke.emitting, "im Stand kein Rauch")
	car.physics.velocity = Vector2(600, 0)
	car.physics.sliding = true
	car.physics.heading = 0.6
	car._physics_process(1.0 / 60.0)
	check(smoke.emitting, "im Drift raucht es")
	car.free()
