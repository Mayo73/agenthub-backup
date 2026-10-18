extends "res://tests/base_test.gd"

var P := Vector3(0, -20, 0)


func test_jaeger_jagt_kleinen() -> void:
	var result := FishBrain.decide("jaeger", P, 1.8, 18.0, P + Vector3(10, 0, 0), 1.0, null)
	check_eq(result, Vector3(1, 0, 0), "Jäger schwimmt zu kleinem Spieler")


func test_jaeger_meidet_grossen() -> void:
	var result := FishBrain.decide("jaeger", P, 1.8, 18.0, P + Vector3(10, 0, 0), 2.0, null)
	check_eq(result, Vector3.ZERO, "Jäger ignoriert größeren Spieler")


func test_ausser_sicht() -> void:
	var result := FishBrain.decide("jaeger", P, 1.8, 18.0, P + Vector3(30, 0, 0), 1.0, null)
	check_eq(result, Vector3.ZERO, "Jäger reagiert nicht auf Spieler außerhalb der Sichtweite")


func test_beute_flieht() -> void:
	var result := FishBrain.decide("scheu", P, 1.0, 10.0, P + Vector3(0, 0, 5), 1.0, null)
	check_eq(result, Vector3(0, 0, -1), "Beute flieht vor gleich großem Spieler")


func test_beute_bleibt_bei_kleinem() -> void:
	var result := FishBrain.decide("scheu", P, 1.0, 10.0, P + Vector3(0, 0, 5), 0.5, null)
	check_eq(result, Vector3.ZERO, "Beute ignoriert kleineren Spieler")


func test_schwarm() -> void:
	var result := FishBrain.decide("schwarm", P, 0.6, 12.0, P + Vector3(100, 0, 0), 1.0, P + Vector3(0, 10, 0))
	check_eq(result, Vector3(0, 1, 0), "Schwarmfisch schwimmt zu Schwarmmitte")
	var result_close := FishBrain.decide("schwarm", P, 0.6, 12.0, P + Vector3(100, 0, 0), 1.0, P + Vector3(0, 2, 0))
	check_eq(result_close, Vector3.ZERO, "Schwarmfisch in Distanz bleibt stehen")


func test_lenken_geradeaus() -> void:
	var m := FishMotion.new()
	var result := FishBrain.steer(m, Vector3(0, 0, -1))
	check_eq(result.x, 1.0, "thrust geradeaus")
	check_eq(result.y, 0.0, "turn geradeaus")
	check_eq(result.z, 0.0, "climb geradeaus")


func test_lenken_links() -> void:
	var m := FishMotion.new()
	var result_left := FishBrain.steer(m, Vector3(-1, 0, 0))
	var result_right := FishBrain.steer(m, Vector3(1, 0, 0))
	check_eq(result_left.y, 1.0, "links: turn = 1")
	check_eq(result_right.y, -1.0, "rechts: turn = -1")


func test_lenken_hoch() -> void:
	var m := FishMotion.new()
	var result_up := FishBrain.steer(m, Vector3(0, 1, 0))
	var result_none := FishBrain.steer(m, Vector3.ZERO)
	check_eq(result_up.z, 1.0, "hoch: climb = 1")
	check_eq(result_none.x, 0.3, "keine Richtung: cruise = 0.3")


func test_folgt_richtung() -> void:
	var m := FishMotion.new()
	m.yaw = 2.0
	for i in range(60):
		var c := FishBrain.steer(m, Vector3(0, 0, -1))
		m.step(c.x, c.y, c.z, 0.05)
	check(absf(m.yaw) < 0.2, "Fisch richtet sich nach 60 Schritten auf -z aus")


func test_jaeger_flieht_vor_riesen() -> void:
	## Spieler ist deutlich größer (2.5 > 1.8 * 1.2 = 2.16), Jäger flieht nach links (-x)
	var result := FishBrain.decide("jaeger", P, 1.8, 18.0, P + Vector3(10, 0, 0), 2.5, null)
	check_eq(result, Vector3(-1, 0, 0), "Jäger flieht vor deutlich größerem Spieler")


func test_jaeger_grenze() -> void:
	## Bei exakter Grenze (1.8 * 1.2 = 2.16): Jäger flieht
	var result := FishBrain.decide("jaeger", P, 1.8, 18.0, P + Vector3(10, 0, 0), 1.8 * FishBrain.HUNTER_FLEE_FACTOR, null)
	check_eq(result, Vector3(-1, 0, 0), "Jäger flieht bei Grenzwert")
	## Bei 2.1 (unter Grenze von 2.16): Jäger bleibt gleichgültig
	var result_below := FishBrain.decide("jaeger", P, 1.8, 18.0, P + Vector3(10, 0, 0), 2.1, null)
	check_eq(result_below, Vector3.ZERO, "Jäger bei Größe knapp unter Grenze")


func test_riese_ausser_sicht() -> void:
	## Spieler ist größer, aber außerhalb der Sichtweite (Dist 30 > sight 18)
	var result := FishBrain.decide("jaeger", P, 1.8, 18.0, P + Vector3(30, 0, 0), 2.5, null)
	check_eq(result, Vector3.ZERO, "Jäger ignoriert riesigen Spieler außerhalb der Sicht")
