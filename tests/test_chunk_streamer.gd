extends "res://tests/base_test.gd"

var streamer: ChunkStreamer


func setup() -> void:
	streamer = ChunkStreamer.new(SeafloorHeight.new(7))
	(Engine.get_main_loop() as SceneTree).root.add_child(streamer)


func teardown() -> void:
	streamer.free()


func test_start() -> void:
	streamer.follow(Vector3(10, -20, 10))
	check_eq(streamer.view_count(), 25, "5 × 5 Kacheln")
	check(streamer.has_chunk(Vector2i(0, 0)), "Kachel unter dem Fisch")
	check_eq(String(streamer.name), "Chunks", "Name des Knotens")


func test_weiter() -> void:
	streamer.follow(Vector3(10, -20, 10))
	streamer.follow(Vector3(10 + 64, -20, 10))
	check_eq(streamer.view_count(), 25, "weiter 25 Kacheln")
	check(streamer.has_chunk(Vector2i(3, 0)), "neue Kachel vorne")
	check(not streamer.has_chunk(Vector2i(-2, 0)), "alte Kachel hinten entfernt")


func test_gleich_bleiben() -> void:
	streamer.follow(Vector3(10, -20, 10))
	streamer.follow(Vector3(10, -20, 10))
	check_eq(streamer.get_child_count(), 25, "keine doppelten Kinder")
