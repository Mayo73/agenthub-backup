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
