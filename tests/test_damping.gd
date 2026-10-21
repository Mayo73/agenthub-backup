extends "res://tests/base_test.gd"

## Tests für Dämpfung in 2D und 3D.


func test_ohne() -> void:
	# Bei damp <= 0 wird kein Dämpfung angewendet, Faktor ist 1.0
	check_eq(Damping.apply(Vector2(3, 4), 0.0, 0.1), Vector2(3, 4))
	check_eq(Damping.factor(-1.0, 1.0), 1.0)


func test_halbwertszeit() -> void:
	# half_life(2.0) soll etwa log(2)/2 = 0.3466 sein
	var hl := Damping.half_life(2.0)
	check(abs(hl - 0.3466) < 0.01, "half_life(2.0) etwa 0.3466")

	# Nach Halbwertszeit sollte die Geschwindigkeit halbiert sein
	var v := Vector2(10, 0)
	var result := Damping.apply(v, 2.0, hl)
	check_eq(result.x, 5.0, "nach Halbwertszeit ist Geschwindigkeit halbiert")


func test_schrittweite() -> void:
	# Bei kleineren Schrittweiten soll das Ergebnis gleich stark gedämpft sein
	var v := Vector2(8, 0)

	# 120-mal mit kleiner Schrittweite dämpfen
	for i in range(120):
		v = Damping.apply(v, 1.0, 1.0 / 120.0)

	# Einmalige Dämpfung mit Gesamt-Delta-Zeit 1.0
	var v_ref := Damping.apply(Vector2(8, 0), 1.0, 1.0)

	check(abs(v.x - v_ref.x) < 0.001, "Ergebnis nach 120 Schritten nahe an Einzelschritt")


func test_ruhe() -> void:
	# Sehr kleine Geschwindigkeiten werden auf NULL gesetzt
	var v := Vector3(0.0005, 0, 0)
	check_eq(Damping.apply_3d(v, 1.0, 0.01), Vector3.ZERO)
	check_eq(Damping.apply_angular(0.0005, 1.0, 0.01), 0.0)
