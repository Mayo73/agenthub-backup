class_name SpawnRing
extends RefCounted
## Liefert Startlagen in einem Ring um den Fisch und sagt, was zu weit weg ist.

const MIN_DISTANCE := 40.0
const MAX_DISTANCE := 110.0
const DESPAWN_DISTANCE := 160.0
const TAU := 2.0 * PI

var rng := RandomNumberGenerator.new()


func _init(seed_value: int = 1) -> void:
	rng.seed = seed_value


func next_position(center: Vector3, floor: SeafloorHeight) -> Vector3:
	var angle := rng.randf_range(0.0, TAU)
	var distance := rng.randf_range(MIN_DISTANCE, MAX_DISTANCE)

	var x := center.x + distance * cos(angle)
	var z := center.z + distance * sin(angle)

	var floor_height := floor.height_at(x, z)
	var y := rng.randf_range(floor_height + 1.0, 0.0)

	return FloorClamp.clamp_to_water(Vector3(x, y, z), floor)


func near_floor_position(center: Vector3, floor: SeafloorHeight) -> Vector3:
	var angle := rng.randf_range(0.0, TAU)
	var distance := rng.randf_range(MIN_DISTANCE, MAX_DISTANCE)

	var x := center.x + distance * cos(angle)
	var z := center.z + distance * sin(angle)

	var floor_height := floor.height_at(x, z)
	var y := floor_height + 1.5

	return Vector3(x, y, z)


static func flat_distance(a: Vector3, b: Vector3) -> float:
	var dx := a.x - b.x
	var dz := a.z - b.z
	return sqrt(dx * dx + dz * dz)


static func is_far(p: Vector3, center: Vector3) -> bool:
	return flat_distance(p, center) > DESPAWN_DISTANCE
