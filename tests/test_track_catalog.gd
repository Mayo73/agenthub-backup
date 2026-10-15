extends "res://tests/base_test.gd"

var catalog: TrackCatalog


func setup() -> void:
	catalog = TrackCatalog.new()


func test_standardstrecke() -> void:
	check(catalog.has_track(TrackCatalog.DEFAULT_ID), "DEFAULT_ID sollte existieren")
	var ids := catalog.ids()
	check(ids.has("hafen"), "ids() sollte 'hafen' enthalten")


func test_hafenring() -> void:
	check_eq(catalog.name_of("hafen"), "Hafenring", "name_of('hafen') sollte Hafenring sein")
	check_eq(catalog.width_of("hafen"), 280.0, "width_of('hafen') sollte 280.0 sein")
	var points := catalog.points_of("hafen")
	check_eq(points.size(), 13, "points_of('hafen').size() sollte 13 sein")
	check_eq(points[1], Vector2(1400, 0), "points_of('hafen')[1] sollte Vector2(1400, 0) sein")


func test_unbekannt() -> void:
	check(not catalog.has_track("gibtsnicht"), "has_track('gibtsnicht') sollte falsch sein")
	check_eq(catalog.name_of("gibtsnicht"), "", "name_of('gibtsnicht') sollte '' sein")
	check_eq(catalog.points_of("gibtsnicht").size(), 0, "points_of('gibtsnicht').size() sollte 0 sein")
	check_eq(catalog.width_of("gibtsnicht"), 280.0, "width_of('gibtsnicht') sollte 280.0 sein")


func test_jede_strecke_hat_genug_punkte() -> void:
	for id in catalog.ids():
		check(catalog.points_of(id).size() >= 4, "Strecke '" + id + "' sollte mindestens 4 Punkte haben")
		check(catalog.name_of(id) != "", "Strecke '" + id + "' sollte einen Namen haben")


func test_drei_strecken() -> void:
	check_eq(TrackCatalog.ids().size(), 3, "drei Strecken im Katalog")
	check(TrackCatalog.has_track("altstadt"), "Altstadtkurs fehlt")
	check(TrackCatalog.has_track("kurvenring"), "Kurvenring fehlt")


## Die Strecke darf sich nicht selbst berühren: Stellen, die entlang der Strecke weit
## auseinander liegen, müssen auch räumlich mindestens 1,3 Streckenbreiten Abstand haben.
func test_strecken_ueberlappen_nicht() -> void:
	for id in TrackCatalog.ids():
		var width := TrackCatalog.width_of(id)
		var path := TrackPath.new(TrackPath.smooth_closed(TrackCatalog.points_of(id), 10), width)
		var along := PackedFloat32Array()
		var dist := 0.0
		for i in path.points.size():
			along.append(dist)
			dist += path.points[i].distance_to(path.points[(i + 1) % path.points.size()])
		var worst := INF
		for i in path.points.size():
			for j in range(i + 1, path.points.size()):
				var gap := absf(along[j] - along[i])
				gap = minf(gap, path.length - gap)
				if gap > width * 2.5:
					worst = minf(worst, path.points[i].distance_to(path.points[j]))
		check(worst >= width * 1.3, "Strecke '%s' kommt sich zu nahe (%.0f)" % [id, worst])


## Kurven dürfen nicht enger sein als die halbe Streckenbreite, sonst knickt der Innenrand.
func test_kurven_nicht_zu_eng() -> void:
	for id in TrackCatalog.ids():
		var width := TrackCatalog.width_of(id)
		var pts := TrackPath.smooth_closed(TrackCatalog.points_of(id), 10)
		var n := pts.size()
		var tightest := INF
		for i in n:
			var a := pts[(i - 3 + n) % n]
			var b := pts[i]
			var c := pts[(i + 3) % n]
			var cross := absf((b - a).cross(c - a))
			if cross < 0.001:
				continue
			var radius := a.distance_to(b) * b.distance_to(c) * c.distance_to(a) / (2.0 * cross)
			tightest = minf(tightest, radius)
		check(tightest >= width * 0.6, "Strecke '%s' hat eine zu enge Kurve (Radius %.0f)" % [id, tightest])
