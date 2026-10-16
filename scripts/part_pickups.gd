class_name PartPickups
extends RefCounted
## Teilefunde im Wasser (wie die Meteoritensplitter bei Spore). Wer einen berührt, bekommt ein neues Teil.

const RADIUS := 9.0

var positions: Array[Vector2] = []
var rng := RandomNumberGenerator.new()


func _init(seed_value: int = 1) -> void:
	rng.seed = seed_value


## Legt einen Fund im Ring um center an und gibt seine Lage zurück.
func spawn_around(center: Vector2, min_dist: float, max_dist: float) -> Vector2:
	var pos := center + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(min_dist, max_dist)
	positions.append(pos)
	return pos


## Entfernt alle Funde, die den Kreis um center mit radius berühren, und gibt ihre Anzahl zurück.
func take_touching(center: Vector2, radius: float) -> int:
	var kept: Array[Vector2] = []
	for p in positions:
		if center.distance_to(p) > radius + RADIUS:
			kept.append(p)
	var taken := positions.size() - kept.size()
	positions = kept
	return taken


## Entfernt alle Funde, die weiter als max_dist von center liegen, und gibt ihre Anzahl zurück.
func remove_far(center: Vector2, max_dist: float) -> int:
	var kept: Array[Vector2] = []
	for p in positions:
		if center.distance_to(p) <= max_dist:
			kept.append(p)
	var removed := positions.size() - kept.size()
	positions = kept
	return removed
