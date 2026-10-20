extends RefCounted
class_name WorldChunks

## Größe einer Kachel in Metern
const SIZE := 64.0

## Abstand in Kacheln um den Fisch herum (5x5 Kacheln)
const RADIUS := 2

var loaded: Dictionary = {}

static func chunk_of(p: Vector3) -> Vector2i:
	return Vector2i(floori(p.x / SIZE), floori(p.z / SIZE))

static func origin_of(c: Vector2i) -> Vector3:
	return Vector3(c.x * SIZE, 0.0, c.y * SIZE)

static func needed(center: Vector3) -> Array[Vector2i]:
	var center_chunk := chunk_of(center)
	var result := [] as Array[Vector2i]
	for x in range(-RADIUS, RADIUS + 1):
		for y in range(-RADIUS, RADIUS + 1):
			result.append(Vector2i(center_chunk.x + x, center_chunk.y + y))
	return result

func update(center: Vector3) -> Dictionary:
	var needed_chunks := needed(center)
	var load := [] as Array[Vector2i]
	var unload := [] as Array[Vector2i]

	for chunk in needed_chunks:
		if not loaded.has(chunk):
			load.append(chunk)

	var to_remove := []
	for key in loaded.keys():
		to_remove.append(key)

	for chunk in to_remove:
		if not needed_chunks.has(chunk):
			unload.append(chunk)
		else:
			pass

	unload.sort()

	for chunk in load:
		loaded[chunk] = true

	for chunk in unload:
		loaded.erase(chunk)

	return {"load": load, "unload": unload}
