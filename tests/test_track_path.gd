extends "res://tests/base_test.gd"

## Quadratische Teststrecke: 0,0 -> 100,0 -> 100,100 -> 0,100, Breite 40, Länge 400.
var track: TrackPath


func setup() -> void:
	track = TrackPath.new(PackedVector2Array([Vector2(0, 0), Vector2(100, 0), Vector2(100, 100), Vector2(0, 100)]), 40.0)


func test_laenge() -> void:
	check_eq(track.length, 400.0)


func test_naechster_punkt_und_fortschritt() -> void:
	var c := track.closest(Vector2(50, -10))
	check_eq(c["position"], Vector2(50, 0), "nächster Punkt")
	check_eq(c["offset"], 10.0, "Abstand zur Mitte")
	check_eq(c["progress"], 50.0, "Fortschritt")
	check_eq(track.progress_at(Vector2(110, 50)), 150.0, "Fortschritt auf der zweiten Geraden")


func test_auf_der_strecke() -> void:
	check(track.is_on_track(Vector2(50, -15)), "15 neben der Mitte ist auf der Strecke")
	check(not track.is_on_track(Vector2(50, -25)), "25 neben der Mitte ist daneben")


func test_richtung() -> void:
	check_eq(track.direction_at(Vector2(50, -10)), Vector2(1, 0), "erste Gerade nach rechts")
	check_eq(track.direction_at(Vector2(110, 50)), Vector2(0, 1), "zweite Gerade nach unten")


func test_start() -> void:
	check_eq(track.start_position(), Vector2(0, 0))
	check_eq(track.start_heading(), 0.0)


func test_umriss() -> void:
	var outer := track.outline(20.0)
	var inner := track.outline(-20.0)
	check(Geometry2D.is_point_in_polygon(Vector2(50, -15), outer), "Außenkante umschließt die Fahrbahn")
	check(not Geometry2D.is_point_in_polygon(Vector2(50, -15), inner), "Fahrbahn liegt außerhalb der Innenkante")
	check(Geometry2D.is_point_in_polygon(Vector2(50, 50), inner), "Mitte liegt innerhalb der Innenkante")


func test_glaetten_laeuft_durch_kontrollpunkte() -> void:
	var control := PackedVector2Array([Vector2(0, 0), Vector2(100, 0), Vector2(100, 100), Vector2(0, 100)])
	var smooth := TrackPath.smooth_closed(control, 4)
	check_eq(smooth.size(), 16, "4 Punkte pro Abschnitt")
	check_eq(smooth[0], control[0])
	check_eq(smooth[4], control[1])


func test_punkt_nach_strecke() -> void:
	var square := TrackPath.new(PackedVector2Array([Vector2(0, 0), Vector2(2000, 0), Vector2(2000, 2000), Vector2(0, 2000)]), 280.0)
	check(square.point_at(0.0).distance_to(Vector2(0, 0)) < 0.01, "point_at(0.0)")
	check(square.point_at(500.0).distance_to(Vector2(500, 0)) < 0.01, "point_at(500.0)")
	check(square.point_at(2500.0).distance_to(Vector2(2000, 500)) < 0.01, "point_at(2500.0)")
	check(square.point_at(8500.0).distance_to(Vector2(500, 0)) < 0.01, "point_at(8500.0)")
	check(square.point_at(-500.0).distance_to(Vector2(0, 500)) < 0.01, "point_at(-500.0)")
