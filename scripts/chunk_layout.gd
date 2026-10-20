class_name ChunkLayout
extends RefCounted
## Layout von Seegras und Felsen auf einer Kachel, reproduzierbar aus Seed.

const WEEDS := 18
const ROCKS := 5

## Je Eintrag: {"kind": "seegras" oder "fels", "position": Vector3, "height": float, "bend": float}
var chunk: Vector2i
var items: Array[Dictionary] = []


func _init(c: Vector2i, floor: SeafloorHeight) -> void:
	chunk = c
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_for(c)

	for i in WEEDS:
		if _try_add_seagrass(rng, floor):
			pass

	for i in ROCKS:
		_add_rock(rng, floor)


func seed_for(c: Vector2i, world_seed: int = 7) -> int:
	return hash([c.x, c.y, world_seed])


func _try_add_seagrass(rng: RandomNumberGenerator, floor: SeafloorHeight) -> bool:
	var origin := WorldChunks.origin_of(chunk)
	var x := origin.x + rng.randf_range(0.0, WorldChunks.SIZE)
	var z := origin.z + rng.randf_range(0.0, WorldChunks.SIZE)

	if floor.is_trench(x, z):
		return false

	var y := floor.height_at(x, z)
	var height := rng.randf_range(3.0, 12.0)
	var bend := rng.randf_range(-0.6, 0.6)

	items.append({"kind": "seegras", "position": Vector3(x, y, z), "height": height, "bend": bend})
	return true


func _add_rock(rng: RandomNumberGenerator, floor: SeafloorHeight) -> void:
	var origin := WorldChunks.origin_of(chunk)
	var x := origin.x + rng.randf_range(0.0, WorldChunks.SIZE)
	var z := origin.z + rng.randf_range(0.0, WorldChunks.SIZE)

	var y := floor.height_at(x, z)
	var height := rng.randf_range(1.5, 6.0)

	items.append({"kind": "fels", "position": Vector3(x, y, z), "height": height, "bend": 0.0})


func count(kind: String) -> int:
	var n := 0
	for item in items:
		if item["kind"] == kind:
			n += 1
	return n
