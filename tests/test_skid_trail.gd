extends "res://tests/base_test.gd"

var skid_trail: SkidTrail


func setup() -> void:
	skid_trail = SkidTrail.new()


func test_spur_beginnt_beim_markieren() -> void:
	skid_trail.update(Vector2(0, 0), true)
	check_eq(skid_trail.trails.size(), 1, "sollte eine Spur haben")
	check_eq(skid_trail.point_count(), 1, "point_count sollte 1 sein")


func test_mindestabstand() -> void:
	skid_trail.update(Vector2(0, 0), true)
	skid_trail.update(Vector2(3, 0), true)  # zu nah, soll nicht hinzugefügt werden
	skid_trail.update(Vector2(10, 0), true)  # genug Abstand, wird hinzugefügt
	skid_trail.update(Vector2(12, 0), true)  # zu nah (nur 2px von 10,0), soll nicht hinzugefügt werden
	skid_trail.update(Vector2(20, 0), true)  # genug Abstand (8px), wird hinzugefügt

	check_eq(skid_trail.point_count(), 3, "sollte genau 3 Punkte haben")


func test_neue_spur_nach_pause() -> void:
	skid_trail.update(Vector2(0, 0), true)   # Spur beginnt
	skid_trail.update(Vector2(10, 0), true)  # zweiter Punkt
	skid_trail.update(Vector2(20, 0), false) # Spur beendet
	skid_trail.update(Vector2(30, 0), true)  # neue Spur beginnt

	check_eq(skid_trail.trails.size(), 2, "sollte 2 Spuren haben")
	check_eq(skid_trail.trails[1][0], Vector2(30, 0), "erster Punkt der neuen Spur sollte (30,0) sein")


func test_ohne_markieren_keine_spur() -> void:
	skid_trail.update(Vector2(0, 0), false)
	skid_trail.update(Vector2(10, 0), false)
	skid_trail.update(Vector2(20, 0), false)
	skid_trail.update(Vector2(30, 0), false)
	skid_trail.update(Vector2(40, 0), false)

	check_eq(skid_trail.trails.size(), 0, "sollte keine Spuren haben")


func test_obergrenze() -> void:
	for i in range(500):
		skid_trail.update(Vector2(i * 10, 0), true)

	check_eq(skid_trail.point_count(), 400, "point_count sollte MAX_POINTS=400 betragen")
	check_eq(skid_trail.trails[0][0], Vector2(1000, 0), "erster Punkt sollte (1000,0) sein")


func test_clear() -> void:
	skid_trail.update(Vector2(0, 0), true)
	skid_trail.update(Vector2(10, 0), true)
	skid_trail.update(Vector2(20, 0), true)

	skid_trail.clear()

	check_eq(skid_trail.point_count(), 0, "point_count sollte nach clear() 0 sein")
