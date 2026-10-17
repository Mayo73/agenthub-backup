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


func test_deko_bilder() -> void:
	var track: Node2D = preload("res://scripts/track.gd").new()
	check(track.TREE_TEXTURE.get_width() > 0, "TREE_TEXTURE width sollte größer als 0 sein")
	check(track.TIRES_TEXTURE.get_width() > 0, "TIRES_TEXTURE width sollte größer als 0 sein")
	check_eq(track.TREE_SIZE, Vector2(92, 96), "TREE_SIZE sollte Vector2(92, 96) sein")
	track.free()


func test_kachel_uvs() -> void:
	var uvs := preload("res://scripts/track.gd").tile_uvs(PackedVector2Array([Vector2(256, 512), Vector2(-128, 0)]))
	var expected := PackedVector2Array([Vector2(1, 2), Vector2(-0.5, 0)])
	check_eq(uvs.size(), expected.size(), "tile_uvs sollte gleich viele Punkte zurückgeben")
	for i in uvs.size():
		check_eq(uvs[i], expected[i], "uv[" + str(i) + "] sollte korrekt sein")


func test_rasen_rechteck() -> void:
	var outline := PackedVector2Array([Vector2(0, 0), Vector2(100, 50)])
	var rect := preload("res://scripts/track.gd").grass_rect(outline)
	check_eq(rect.size(), 4, "rasen_rect sollte 4 Punkte haben")
	check_eq(rect[0], Vector2(-4000, -4000), "erster Punkt sollte (-4000, -4000) sein")
	check_eq(rect[2], Vector2(4100, 4050), "dritter Punkt sollte (4100, 4050) sein")

	var empty_rect := preload("res://scripts/track.gd").grass_rect(PackedVector2Array())
	check(empty_rect.is_empty(), "rasen_rect(leer) sollte leer sein")


func test_texturen_geladen() -> void:
	var track_class := preload("res://scripts/track.gd")
	check(track_class.ROAD_TEXTURE != null, "ROAD_TEXTURE sollte nicht null sein")
	check(track_class.GRASS_TEXTURE != null, "GRASS_TEXTURE sollte nicht null sein")

	var track := track_class.new()
	Engine.get_main_loop().root.add_child(track)
	check(track.texture_repeat == CanvasItem.TEXTURE_REPEAT_ENABLED,
		"texture_repeat sollte TEXTURE_REPEAT_ENABLED sein nach _ready()")
	track.free()
