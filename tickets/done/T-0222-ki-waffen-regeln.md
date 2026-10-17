---
id: T-0222
title: Waffen der KI-Arten berechnen (SpeciesWeapons)
project: zellenphase
priority: 2
---
## Ziel
Bisher sind Stacheln, Giftdrüsen und Elektroorgan der KI-Arten nur gezeichnet. Eine Logik-Klasse berechnet, wo die Stachelspitzen einer KI-Zelle liegen und welche Arten Gift oder ein Elektroorgan haben. Eingebaut wird sie in späteren Tickets.

## Dateien
- `scripts/species_weapons.gd` – neu
- `tests/test_species_weapons.gd` – neu

## Akzeptanzkriterien
`scripts/species_weapons.gd` genau so:
```gdscript
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
```
- Keine andere Datei ändern.

## Tests
`tests/test_species_weapons.gd` mit `extends "res://tests/base_test.gd"`:
- `test_stachelkugel`: `var t := SpeciesWeapons.spike_tips("stachelkugel", Vector2.ZERO, 0.0, 18.0)` → `t.size()` ist 8; `t[0]` ist `Vector2(27, 0)`; `t[2].is_equal_approx(Vector2(0, 27))` wahr
- `test_stachelkugel_verschoben`: `var t := SpeciesWeapons.spike_tips("stachelkugel", Vector2(100, 50), 0.0, 18.0)` → `t[0]` ist `Vector2(127, 50)`
- `test_hornjaeger`: `var t := SpeciesWeapons.spike_tips("hornjaeger", Vector2.ZERO, 0.0, 40.0)` → `t.size()` ist 2; `t[0].is_equal_approx(PartGeometry.world_point(Vector2.ZERO, 0.0, 40.0, Vector2(0.7, 0.7).normalized() * 1.6))` wahr
- `test_ohne_stacheln`: `SpeciesWeapons.spike_tips("blasenling", Vector2.ZERO, 0.0, 12.0).size()` ist 0
- `test_gift`: `SpeciesWeapons.has_poison("giftling")` wahr; `SpeciesWeapons.has_poison("schnapper")` falsch; `SpeciesWeapons.count_part("giftling", "gift")` ist 2
- `test_elektro`: `SpeciesWeapons.has_electric("zitterzelle")` wahr; `SpeciesWeapons.has_electric("giftling")` falsch

Review (17.10.2026): gemergt.
