extends "res://tests/base_test.gd"


func test_bild() -> void:
	check(PickupView.TEXTURE != null, "TEXTURE muss gesetzt sein")


func test_rechteck() -> void:
	var r := PickupView.sprite_rect(Vector2(100, 50), 0.0)
	check_eq(r.size.x, PartPickups.RADIUS * 2.0 * 1.3, "Rechteck-Größe bei t=0 falsch")
	check_eq(r.get_center(), Vector2(100, 50), "Rechteck-Mitte falsch")


func test_pulsieren() -> void:
	var r := PickupView.sprite_rect(Vector2.ZERO, PI / 8)
	check_eq(r.size.x, PartPickups.RADIUS * 1.2 * 2.0 * 1.3, "Pulsierende Größe bei t=PI/8 falsch")
