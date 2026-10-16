extends "res://tests/base_test.gd"


func setup() -> void:
	pass


func test_laedt_strecke() -> void:
	var track: Node2D = preload("res://scripts/track.gd").new()
	track.load_track("hafen")
	check_eq(track.track_id, "hafen", "track_id sollte 'hafen' sein")
	check(track.path != null, "path sollte nicht null sein")
	check_eq(track.path.width, 280.0, "path.width sollte 280.0 sein")
	check(track.path.length > 1000.0, "path.length sollte größer als 1000.0 sein")
	track.free()


func test_unbekannte_strecke_ignoriert() -> void:
	var track: Node2D = preload("res://scripts/track.gd").new()
	track.load_track("hafen")
	check_eq(track.track_id, "hafen", "track_id sollte zuerst 'hafen' sein")
	track.load_track("gibtsnicht")
	check_eq(track.track_id, "hafen", "track_id sollte weiterhin 'hafen' sein")
	track.free()


func test_beim_start_geladen() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	Engine.get_main_loop().root.add_child(main)
	check_eq(main.get_node("World/Track").track_id, TrackCatalog.DEFAULT_ID,
		"track_id sollte beim Start DEFAULT_ID sein")
	main.free()


func test_deko_geladen() -> void:
	var track: Node2D = preload("res://scripts/track.gd").new()
	track.load_track("altstadt")
	check(track.decor.size() > 0, "sollte mindestens einen Deko-Eintrag geben")

	var has_tires := false
	var has_tree := false
	for item in track.decor:
		if item["kind"] == TrackDecor.Kind.TIRES:
			has_tires = true
		if item["kind"] == TrackDecor.Kind.TREE:
			has_tree = true
	check(has_tires, "sollte einen Reifenstapel geben")
	check(has_tree, "sollte einen Baum geben")

	check(track.has_method("_draw_decor"), "track sollte Methode _draw_decor haben")
	track.free()


func test_tribuene_geladen() -> void:
	var track: Node2D = preload("res://scripts/track.gd").new()
	track.load_track("kurvenring")
	check_eq(track.stand.size(), 4, "stand sollte 4 Ecken haben")

	for e in track.stand:
		check(not track.path.is_on_track(e), "Ecke der Tribüne sollte nicht auf der Strecke sein")

	track.free()
