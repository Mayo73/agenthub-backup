extends "res://tests/base_test.gd"

func test_anzahl() -> void:
	var a := ElectricArcs.arc(Vector2.ZERO, Vector2(100, 0), 5, 6.0, 1)
	check_eq(a.size(), 6, "Anzahl der Punkte bei 5 Segmenten ist 6")

func test_enden() -> void:
	var a := ElectricArcs.arc(Vector2(10, 20), Vector2(110, 20), 5, 6.0, 3)
	check_eq(a[0], Vector2(10, 20), "Startpunkt ist korrekt")
	check_eq(a[5], Vector2(110, 20), "Endpunkt ist korrekt")

func test_abweichung() -> void:
	var a := ElectricArcs.arc(Vector2.ZERO, Vector2(100, 0), 5, 6.0, 7)
	for i in range(1, 5):
		check_eq(a[i].x, 20.0 * i, "X-Koordinate bei Segment %d ist korrekt" % i)
		check(absf(a[i].y) <= 6.0, "Y-Abweichung bei Punkt %d beträgt max 6.0" % i)

func test_gleicher_seed() -> void:
	var a := ElectricArcs.arc(Vector2.ZERO, Vector2(0, 80), 4, 5.0, 9)
	var b := ElectricArcs.arc(Vector2.ZERO, Vector2(0, 80), 4, 5.0, 9)
	check(a == b, "Gleicher Seed erzeugt gleiche Linie")

func test_mindestens_ein_stueck() -> void:
	var a := ElectricArcs.arc(Vector2.ZERO, Vector2(50, 0), 0, 5.0, 1)
	check_eq(a.size(), 2, "Bei 0 Segments ergibt maxi(1,0)=1 Segment mit 2 Punkten")
