extends "res://tests/base_test.gd"

var p: PoisonClouds

func setup() -> void:
	p = PoisonClouds.new()


func test_ausstossen() -> void:
	check(p.emit(Vector2.ZERO), "erste Wolke wird erzeugt")
	check(not p.emit(Vector2(5, 0)), "sofortige zweite Emission verweigert")
	p.tick(0.5)
	check(p.emit(Vector2(50, 0)), "nach Zeitverzögerung neue Wolke möglich")
	check_eq(p.clouds.size(), 2, "zwei Wolken existieren")


func test_schaden() -> void:
	p.emit(Vector2.ZERO)
	p.tick(0.5)
	p.emit(Vector2(50, 0))
	check_eq(p.damage_at(Vector2(10, 0), 5.0, 1.0), 12.0, "Schaden durch eine Wolke")
	check_eq(p.damage_at(Vector2(200, 0), 5.0, 1.0), 0.0, "kein Schaden außerhalb der Reichweite")


func test_verfliegen() -> void:
	p.emit(Vector2.ZERO)
	p.tick(0.5)
	p.emit(Vector2(50, 0))
	p.tick(2.6)
	check_eq(p.clouds.size(), 1, "eine Wolke ist verfallen")
	p.tick(0.5)
	check_eq(p.clouds.size(), 0, "alle Wolken sind verfallen")
