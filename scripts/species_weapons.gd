class_name SpeciesWeapons
extends RefCounted
## Wirksame Waffen der KI-Arten: Stachelspitzen, Giftdrüsen und Elektroorgan.


## Stachelspitzen einer KI-Zelle in Weltkoordinaten.
## Stachelkugel: acht Spitzen rundum bei 1,5 Radien (wie AiCell.spike_shapes).
## Andere Arten: je Teil "stachel" aus SpeciesParts eine Spitze (wie WeaponRules.spike_tips).
static func spike_tips(species_id: String, center: Vector2, heading: float, radius: float) -> Array[Vector2]:
	var tips: Array[Vector2] = []
	if species_id == "stachelkugel":
		for i in 8:
			tips.append(center + Vector2.from_angle(heading + TAU * i / 8.0) * radius * 1.5)
		return tips
	for part: Dictionary in SpeciesParts.parts_of(species_id):
		if part["id"] != "stachel":
			continue
		var local: Vector2 = part["pos"]
		tips.append(PartGeometry.world_point(center, heading, radius, local.normalized() * (1.0 + WeaponRules.SPIKE_LENGTH)))
	return tips


static func count_part(species_id: String, part_id: String) -> int:
	var n := 0
	for part: Dictionary in SpeciesParts.parts_of(species_id):
		if part["id"] == part_id:
			n += 1
	return n


static func has_poison(species_id: String) -> bool:
	return count_part(species_id, "gift") > 0


static func has_electric(species_id: String) -> bool:
	return count_part(species_id, "elektro") > 0
