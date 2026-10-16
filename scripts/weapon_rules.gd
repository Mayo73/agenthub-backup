class_name WeaponRules
extends RefCounted
## Stacheln: Wer eine Stachelspitze berührt, nimmt Schaden. Nur die Spitze zählt, nicht der Körper.

const SPIKE_DAMAGE := 15.0
## So weit (in Zellradien) ragt die Spitze über den Zellrand hinaus.
const SPIKE_LENGTH := 0.6


## Spitzen aller Stacheln in Weltkoordinaten. Ein Stachel zeigt von der Zellmitte durch seine Lage nach außen.
static func spike_tips(center: Vector2, heading: float, radius: float, build: CellBuild) -> Array[Vector2]:
	var tips: Array[Vector2] = []
	for p in build.parts:
		if p["id"] != "stachel":
			continue
		var local: Vector2 = p["pos"]
		if local == Vector2.ZERO:
			continue
		tips.append(PartGeometry.world_point(center, heading, radius, local.normalized() * (1.0 + SPIKE_LENGTH)))
	return tips


## Wie viele Spitzen den Kreis um target_pos mit target_radius berühren.
static func spike_hits(tips: Array[Vector2], target_pos: Vector2, target_radius: float) -> int:
	var hits := 0
	for t in tips:
		if t.distance_to(target_pos) <= target_radius:
			hits += 1
	return hits
