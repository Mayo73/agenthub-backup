extends "res://tests/base_test.gd"


func test_drift_zieht_spuren() -> void:
	var marks: Node2D = preload("res://scripts/skid_marks.gd").new()
	var car := CarPhysics.new()
	car.velocity = Vector2(600, 0)
	car.steer = 1.0
	car.handbrake = true
	for _i in range(30):
		car.step(1.0 / 60.0)
		marks.track_car(car)
	check(marks.left.point_count() > 2, "links sind mehr als 2 Punkte")
	check(marks.right.point_count() > 2, "rechts sind mehr als 2 Punkte")
	marks.free()


func test_geradeaus_keine_spuren() -> void:
	var marks: Node2D = preload("res://scripts/skid_marks.gd").new()
	var car := CarPhysics.new()
	car.velocity = Vector2(600, 0)
	car.throttle = 1.0
	for _i in range(30):
		car.step(1.0 / 60.0)
		marks.track_car(car)
	check(marks.left.point_count() == 0, "keine Spuren bei Geradeausfahrt")
	marks.free()


func test_spuren_liegen_unter_dem_auto() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)
	var marks := main.get_node("World/SkidMarks")
	check(marks != null, "World/SkidMarks existiert")
	check(marks.get_index() < main.get_node("World/Car").get_index(), "Spuren werden vor dem Auto gezeichnet")
	check(marks.get_index() > main.get_node("World/Track").get_index(), "Spuren liegen über der Strecke")
	main.free()
