extends "res://tests/base_test.gd"

func test_duenne_wand() -> void:
	var result := SweepHit.segment_rect(Vector2(0, 0), Vector2(10, 0), Rect2(5, -5, 0.02, 10))
	check(not result.is_empty(), "Treffer erwartet")
	check_eq(result["t"], 0.5, "t = 0.5 erwartet")
	check_eq(result["position"].x, 5.0, "position.x = 5 erwartet")
	check_eq(result["normal"], Vector2(-1, 0), "normal = (-1, 0) erwartet")


func test_vorbei() -> void:
	var result := SweepHit.segment_rect(Vector2(0, 10), Vector2(10, 10), Rect2(5, -5, 0.02, 10))
	check(result.is_empty(), "Kein Treffer erwartet")


func test_oben() -> void:
	var result := SweepHit.segment_rect(Vector2(5, -10), Vector2(5, 0), Rect2(0, -2, 10, 1))
	check(not result.is_empty(), "Treffer erwartet")
	check_eq(result["normal"], Vector2(0, -1), "normal = (0, -1) erwartet")
	check_eq(result["t"], 0.8, "t = 0.8 erwartet")


func test_erste_wand() -> void:
	var walls: Array[Rect2] = [Rect2(6, -1, 0.1, 2), Rect2(3, -1, 0.1, 2)]
	var result := SweepHit.first_hit(Vector2(0, 0), Vector2(10, 0), walls)
	check(not result.is_empty(), "Treffer erwartet")
	check_eq(result["index"], 1, "index = 1 erwartet (zweite Wand, aber erster Treffer)")
	check_eq(result["position"].x, 3.0, "position.x = 3 erwartet")


func test_hundert_versuche() -> void:
	var treffer := 0

	for i in 100:
		var tempo := 50.0 + i * 4.5
		var staerke := 0.01 + (i % 5) * 0.01
		var winkel := deg_to_rad(-60.0 + (i % 13) * 10.0)
		var v := Vector2(cos(winkel), sin(winkel)) * tempo

		var p := Vector2(0, 0)
		var dt := 1.0 / 120.0
		var wand := Rect2(20, -50, staerke, 100)

		for _step in range(120):
			var erg := SweepHit.segment_rect(p, p + v * dt, wand)
			if not erg.is_empty():
				treffer += 1
				break
			p += v * dt

	check_eq(treffer, 100, "Alle 100 Versuche sollten treffen")


func test_rueckprall() -> void:
	var vel := Vector2(10, 0)
	var norm := Vector2(-1, 0)
	var rest := 0.5
	var result := SweepHit.reflect(vel, norm, rest)
	check_eq(result, Vector2(-5, 0), "Rückprall = (-5, 0) erwartet")
