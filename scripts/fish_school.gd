class_name FishSchool
extends RefCounted
## Verteilung der KI-Fische und Schwarmmitte.

## Waagrechter Abstand der Fische zum Spieler beim Verteilen, in Metern.
const MIN_DIST := 20.0
const MAX_DIST := 60.0
const SWARMS := 2
const SWARM_SIZE := 6
const GRAZERS := 3
const PUFFERS := 2
const PREDATORS := 2


## Plan: Liste von {"id": String, "position": Vector3}. Gleicher seed, gleicher Plan.
static func spawn_plan(center: Vector3, seed_value: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var plan: Array[Dictionary] = []
	for s in SWARMS:
		var mid := _around(center, rng)
		for i in SWARM_SIZE:
			var offset := Vector3(rng.randf_range(-2.0, 2.0), rng.randf_range(-1.0, 1.0), rng.randf_range(-2.0, 2.0))
			plan.append({"id": "silberling", "position": FishWorld.clamp_to_water(mid + offset)})
	for i in GRAZERS:
		plan.append({"id": "grasfisch", "position": _around(center, rng)})
	for i in PUFFERS:
		plan.append({"id": "kugelfisch", "position": _around(center, rng)})
	for i in PREDATORS:
		plan.append({"id": "zackenbarsch", "position": _around(center, rng)})
	return plan


## Zufällige Lage im waagrechten Abstand MIN_DIST bis MAX_DIST (Schwarmversatz bis 2 m kommt dazu), Tiefe 5 bis 50 m.
static func _around(center: Vector3, rng: RandomNumberGenerator) -> Vector3:
	var angle := rng.randf_range(0.0, TAU)
	var dist := rng.randf_range(MIN_DIST + 3.0, MAX_DIST)
	var p := center + Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)
	p.y = -rng.randf_range(5.0, 50.0)
	return FishWorld.clamp_to_water(p)


## Mitte aller Fische einer Art (Knoten mit species_id und motion), null wenn es keinen gibt.
static func flock_center(fishes: Array, species_id: String) -> Variant:
	var sum := Vector3.ZERO
	var n := 0
	for f in fishes:
		if f.species_id == species_id:
			sum += f.motion.position
			n += 1
	if n == 0:
		return null
	return sum / n
