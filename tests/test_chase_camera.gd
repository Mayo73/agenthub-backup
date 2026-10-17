extends "res://tests/base_test.gd"

func test_hinter_dem_fisch() -> void:
	var result := ChaseCamera.target_position(Vector3(0, -20, 0), 0.0)
	check(result.is_equal_approx(Vector3(0, -18.5, 6)), "Kamera soll 6m hinter und 1.5m über dem Fisch schweben")


func test_gedreht() -> void:
	var result := ChaseCamera.target_position(Vector3(0, -20, 0), PI / 2.0)
	check(result.is_equal_approx(Vector3(6, -18.5, 0)), "Kamera soll bei 90° Drehung seitlich hinter dem Fisch sein")


func test_groesse() -> void:
	var result := ChaseCamera.target_position(Vector3(0, -20, 0), 0.0, 2.0)
	check(result.is_equal_approx(Vector3(0, -17, 12)), "Kameraabstand soll mit Fischgröße skalieren")


func test_unter_wasser() -> void:
	var result := ChaseCamera.target_position(Vector3(0, -0.5, 0), 0.0)
	check_eq(result.y, -0.3, "Kamera muss unter Wasser bleiben (y = -0.3)")


func test_folgen() -> void:
	var zero := Vector3.ZERO
	var target := Vector3(10, 0, 0)

	# Bei delta = 0 bleibt die Kamera unverändert
	check(zero.is_equal_approx(ChaseCamera.follow(zero, target, 0.0)), "Bei delta=0 soll keine Bewegung stattfinden")

	# Bei delta = 0.25 wird ein Teil der Strecke zurückgelegt
	var expected_partial := 10.0 * (1.0 - exp(-1.0))
	check(is_equal_approx(ChaseCamera.follow(zero, target, 0.25).x, expected_partial), "Bei delta=0.25 soll teilweise auf Zielpunkt zugefahren werden")

	# Bei großem delta wird der Zielpunkt fast exakt erreicht
	check(ChaseCamera.follow(zero, target, 10.0).is_equal_approx(target), "Bei großem delta soll annähernd Ziel erreicht sein")
