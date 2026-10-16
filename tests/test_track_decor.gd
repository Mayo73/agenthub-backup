extends "res://tests/base_test.gd"

var square: TrackPath


func setup() -> void:
	square = TrackPath.new(PackedVector2Array([Vector2(0, 0), Vector2(2000, 0), Vector2(2000, 2000), Vector2(0, 2000)]), 280.0)


func test_seitenpunkte() -> void:
	var pts := TrackDecor.side_points(square, 1000.0, 200.0)
	check(pts.size() >= 8, "sollte mindestens 8 Punkte haben")
	for p in pts:
		check(square.distance_from_center(p) >= 179.0, "Punkt muss weit genug von Mitte sein")
	var found_left := false
	var found_right := false
	for p in pts:
		if p.distance_to(Vector2(1000, -200)) < 1.0:
			found_left = true
		if p.distance_to(Vector2(1000, 200)) < 1.0:
			found_right = true
	check(found_left, "sollte einen Punkt bei (1000, -200) haben")
	check(found_right, "sollte einen Punkt bei (1000, 200) haben")


func test_ohne_abstand() -> void:
	check(TrackDecor.side_points(square, 0.0, 200.0).size() == 0, "spacing=0 soll keine Punkte ergeben")
	check(TrackDecor.side_points(null, 100.0, 200.0).size() == 0, "null path soll keine Punkte ergeben")


func test_deko_aufbauen() -> void:
	var items := TrackDecor.build(square)
	var found_tires := false
	var found_trees := false
	for item in items:
		if item["kind"] == TrackDecor.Kind.TIRES:
			found_tires = true
			check(square.distance_from_center(item["position"]) >= 180.0, "TIRES muss weit genug von Mitte sein")
		if item["kind"] == TrackDecor.Kind.TREE:
			found_trees = true
	check(found_tires, "sollte mindestens einen Reifenstapel haben")
	check(found_trees, "sollte mindestens einen Baum haben")


func test_echte_strecke() -> void:
	var path := TrackPath.new(TrackPath.smooth_closed(TrackCatalog.points_of("hafen"), 10), 280.0)
	var items := TrackDecor.build(path)
	check(items.size() > 10, "sollte mehr als 10 Deko-Elemente haben")
	for item in items:
		check(not path.is_on_track(item["position"]), "Deko darf nicht auf der Strecke sein")
