class_name ReefLayout
extends RefCounted
## Lage von Seegras und Felsen am Meeresboden der Fischphase, mit festem Seed reproduzierbar.

const WEED_COUNT := 160
const ROCK_COUNT := 40

## Je Eintrag: {"kind": "seegras" oder "fels", "position": Vector3 auf dem Boden, "height": float in Metern}
var items: Array[Dictionary] = []


func _init(seed_value: int = 7) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in WEED_COUNT:
		items.append({"kind": "seegras", "position": random_floor_point(rng), "height": rng.randf_range(3.0, 12.0)})
	for i in ROCK_COUNT:
		items.append({"kind": "fels", "position": random_floor_point(rng), "height": rng.randf_range(1.5, 6.0)})


## Zufälliger Punkt auf dem Meeresboden, mindestens 5 m vom Rand.
static func random_floor_point(rng: RandomNumberGenerator) -> Vector3:
	var r := FishWorld.HALF_SIZE - 5.0
	return Vector3(rng.randf_range(-r, r), -FishWorld.DEPTH, rng.randf_range(-r, r))


func count(kind: String) -> int:
	var n := 0
	for item in items:
		if item["kind"] == kind:
			n += 1
	return n
