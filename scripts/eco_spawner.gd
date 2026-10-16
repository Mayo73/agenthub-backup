class_name EcoSpawner
extends RefCounted
## Wählt Arten und Lagen für neue KI-Zellen um die Spielerzelle.

const TARGET_COUNT := 30
const SPAWN_MIN := 700.0
const SPAWN_MAX := 1300.0
const DESPAWN := 1800.0

var rng := RandomNumberGenerator.new()


func _init(seed_value: int = 1) -> void:
	rng.seed = seed_value


func pick_species(player_stage: int) -> String:
	var ids := SpeciesCatalog.ids_near_stage(player_stage)
	return ids[rng.randi_range(0, ids.size() - 1)]


## Lage im Ring um center; scale vergrößert den Ring mit der Zellgröße (siehe view_scale).
func spawn_position(center: Vector2, scale: float) -> Vector2:
	return center + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(SPAWN_MIN, SPAWN_MAX) * scale


static func missing(current: int) -> int:
	return maxi(0, TARGET_COUNT - current)


## Wie viel weiter die Kamera bei diesem Radius sieht als im ersten Größenabschnitt.
static func view_scale(player_radius: float) -> float:
	return player_radius / CellProgress.radius_for_stage(0)


static func is_too_far(center: Vector2, pos: Vector2, scale: float) -> bool:
	return center.distance_to(pos) > DESPAWN * scale
