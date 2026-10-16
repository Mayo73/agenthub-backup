extends "res://tests/base_test.gd"


func test_keins() -> void:
	check(CellPattern.marks("keins").size() == 0, "marks('keins') sollte keine Elemente zurückgeben")
	check(CellPattern.marks("gibtsnicht").size() == 0, "marks('gibtsnicht') sollte keine Elemente zurückgeben")


func test_punkte() -> void:
	var m := CellPattern.marks("punkte")
	check(m.size() == 12, "marks('punkte') sollte 12 Elemente zurückgeben")
	for e in m:
		check((e["pos"] as Vector2).length() <= 0.7001, "Position von Punkte-Element liegt außerhalb des Radius 0.7")
		check(e["stripe"] == false, "Punkte sollten stripe=false haben")
		check(e["size"] == 0.07, "Punkte sollten size=0.07 haben")


func test_flecken() -> void:
	var m := CellPattern.marks("flecken")
	check(m.size() == 5, "marks('flecken') sollte 5 Elemente zurückgeben")
	for e in m:
		check((e["pos"] as Vector2).length() <= 0.5001, "Position von Flecken-Element liegt außerhalb des Radius 0.5")


func test_streifen() -> void:
	var m := CellPattern.marks("streifen")
	check(m.size() == 5, "marks('streifen') sollte 5 Elemente zurückgeben")
	check(m[0]["stripe"] == true, "erstes Streifen-Element sollte stripe=true haben")
	check((m[4]["pos"] as Vector2).is_equal_approx(Vector2(0.6, 0)), "letztes Streifen-Element sollte bei x=0.6 sein")


func test_reproduzierbar() -> void:
	var a: Vector2 = CellPattern.marks("punkte", 3)[2]["pos"]
	var b: Vector2 = CellPattern.marks("punkte", 3)[2]["pos"]
	check(a.is_equal_approx(b), "gleicher seed_value sollte gleiche Positionen ergeben")


func test_streifenlaenge() -> void:
	check_eq(CellPattern.stripe_half(0.0), 0.8, "stripe_half(0.0) sollte 0.8 sein")
	var h1 := CellPattern.stripe_half(0.6)
	check(h1 >= 0.529 and h1 <= 0.530, "stripe_half(0.6) sollte zwischen 0.529 und 0.530 liegen (war: %s)" % h1)
	check_eq(CellPattern.stripe_half(2.0), 0.0, "stripe_half(2.0) sollte 0.0 sein")


func test_lage() -> void:
	var l := CellLook.new()
	l.set_stretch(1.25)
	var result := CellPattern.to_local(Vector2(0.5, 0.5), 10.0, l)
	check(result.is_equal_approx(Vector2(6.25, 4.0)), "to_local sollte gestreckte Position korrekt berechnen (war: %s)" % result)
