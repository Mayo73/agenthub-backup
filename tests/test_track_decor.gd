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


func test_tribuene_vier_ecken() -> void:
	var s := TrackDecor.grandstand(square)
	check(s.size() == 4, "sollte 4 Ecken haben")
	check(absf(s[0].distance_to(s[1]) - TrackDecor.STAND_LENGTH) < 0.01, "Seitenlänge STAND_LENGTH korrekt")
	check(absf(s[1].distance_to(s[2]) - TrackDecor.STAND_DEPTH) < 0.01, "Tiefe STAND_DEPTH korrekt")


func test_tribuene_neben_strecke() -> void:
	var path := TrackPath.new(TrackPath.smooth_closed(TrackCatalog.points_of("hafen"), 10), 280.0)
	var s := TrackDecor.grandstand(path)
	for ecke in s:
		check(not path.is_on_track(ecke), "Ecke darf nicht auf der Strecke sein")
	var center := (s[0] + s[2]) * 0.5
	var dist := center.distance_to(path.start_position())
	check(dist >= 200.0 and dist <= 400.0, "Mittelpunkt sollte 200-400 Pixel von Start entfernt sein")


func test_tribuene_ohne_strecke() -> void:
	check(TrackDecor.grandstand(null).size() == 0, "null path soll keine Ecken ergeben")


func test_abwandlung() -> void:
	var v0 := TrackDecor.variation(0)
	check(v0["scale"] == 1.0 and v0["flip"] == false, "variation(0) sollte {scale:1.0, flip:false}")
	var v1 := TrackDecor.variation(1)
	check(v1["flip"] == true, "variation(1)['flip'] sollte true sein")
	var v2 := TrackDecor.variation(2)
	check(v2["scale"] == 1.18, "variation(2)['scale'] sollte 1.18 sein")
	var v5 := TrackDecor.variation(5)
	check(v5["scale"] == 1.0, "variation(5)['scale'] sollte 1.0 sein (wiederholung)")
	var vn1 := TrackDecor.variation(-1)
	check(vn1["flip"] == true, "variation(-1)['flip'] sollte true sein")


func test_deko_abgewandelt() -> void:
	var items := TrackDecor.build(square)
	check(items.size() > 0, "sollte Deko-Elemente haben")
	for item in items:
		check(item.has("scale"), "jeder Eintrag hat 'scale'")
		check(item.has("flip"), "jeder Eintrag hat 'flip'")
	var first_scale: float = items[0]["scale"]
	check(first_scale == 1.0, "items[0]['scale'] sollte 1.0 sein")
	var has_flip := false
	var scales: Array[float] = []
	for item in items:
		if item["flip"]:
			has_flip = true
		scales.append(item["scale"])
	check(has_flip, "mindestens ein Eintrag hat 'flip' wahr")
	var unique_scales: Array[float] = []
	for sc in scales:
		var found: bool = false
		for existing in unique_scales:
			if existing == sc:
				found = true
				break
		if not found:
			unique_scales.append(sc)
	check(unique_scales.size() >= 2, "mindestens zwei verschiedene 'scale'-Werte kommen vor")


func test_gleich_bei_jedem_start() -> void:
	var items1 := TrackDecor.build(square)
	var items2 := TrackDecor.build(square)
	check(items1 == items2, "beide Ergebnisse sind gleich")
