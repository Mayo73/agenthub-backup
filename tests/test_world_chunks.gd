extends "res://tests/base_test.gd"

var world_chunks: WorldChunks

func setup() -> void:
	world_chunks = WorldChunks.new()

func test_kachel() -> void:
	var chunk1 := WorldChunks.chunk_of(Vector3(10, -20, 10))
	check_eq(chunk1.x, 0, "chunk_of(10, -20, 10) x")
	check_eq(chunk1.y, 0, "chunk_of(10, -20, 10) y")

	var chunk2 := WorldChunks.chunk_of(Vector3(-1, 0, 130))
	check_eq(chunk2.x, -1, "chunk_of(-1, 0, 130) x")
	check_eq(chunk2.y, 2, "chunk_of(-1, 0, 130) y")

func test_ursprung() -> void:
	var origin := WorldChunks.origin_of(Vector2i(-1, 2))
	check_eq(origin.x, -64.0, "origin_of(-1, 2) x")
	check_eq(origin.y, 0.0, "origin_of(-1, 2) y")
	check_eq(origin.z, 128.0, "origin_of(-1, 2) z")

func test_gebraucht() -> void:
	var needed := WorldChunks.needed(Vector3.ZERO)
	check_eq(needed.size(), 25, "needed size")

	var first := needed[0]
	check_eq(first.x, -2, "needed first x")
	check_eq(first.y, -2, "needed first y")

	var last := needed[needed.size() - 1]
	check_eq(last.x, 2, "needed last x")
	check_eq(last.y, 2, "needed last y")

func test_erstes_update() -> void:
	world_chunks = WorldChunks.new()
	var result := world_chunks.update(Vector3.ZERO)
	check_eq(result.load.size(), 25, "load count first update")
	check_eq(result.unload.size(), 0, "unload count first update")
	check_eq(world_chunks.loaded.size(), 25, "loaded size after first update")

func test_weiterschwimmen() -> void:
	world_chunks = WorldChunks.new()
	world_chunks.update(Vector3.ZERO)

	var result := world_chunks.update(Vector3(64, 0, 0))
	check_eq(result.load.size(), 5, "load count swim")
	for chunk in result.load:
		check_eq(chunk.x, 3, "load chunks all have x = 3")

	check_eq(result.unload.size(), 5, "unload count swim")
	for chunk in result.unload:
		check_eq(chunk.x, -2, "unload chunks all have x = -2")

	check_eq(world_chunks.loaded.size(), 25, "loaded size after swim")

func test_gleiche_kachel() -> void:
	world_chunks = WorldChunks.new()
	world_chunks.update(Vector3(5, 0, 5))

	var result1 := world_chunks.update(Vector3(5, 0, 5))
	check_eq(result1.load.size(), 0, "second update load count")
	check_eq(result1.unload.size(), 0, "second update unload count")
