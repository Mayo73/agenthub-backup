---
id: T-0110
title: Stacheln und Lage der Teile (PartGeometry, WeaponRules)
project: zellenphase
priority: 3
after: T-0103
---
## Ziel
Stacheln verletzen, was ihre Spitze berührt. Lage und Ausrichtung zählen: Ein Stachel hinten schützt nur von hinten. Dazu eine kleine Hilfsklasse, die Teil-Lagen in Weltkoordinaten umrechnet.

## Dateien
- `scripts/part_geometry.gd`: neu
- `scripts/weapon_rules.gd`: neu
- `tests/test_weapon_rules.gd`: neu

## Akzeptanzkriterien
- `scripts/part_geometry.gd` genau so:
```gdscript
class_name PartGeometry
extends RefCounted
## Umrechnung von Teil-Lagen (in Zellradien, Blick nach +x) in Weltkoordinaten.


static func world_point(center: Vector2, heading: float, radius: float, local: Vector2) -> Vector2:
	return center + (local * radius).rotated(heading)
```
- `scripts/weapon_rules.gd` genau so:
```gdscript
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
```

## Tests
`tests/test_weapon_rules.gd` mit `extends "res://tests/base_test.gd"`:
- `test_weltpunkt`: `PartGeometry.world_point(Vector2(10, 0), 0.0, 10.0, Vector2(1, 0))` ist (20, 0); `PartGeometry.world_point(Vector2.ZERO, PI / 2, 10.0, Vector2(1, 0)).is_equal_approx(Vector2(0, 10))` wahr
- `test_spitzen`: `var b := CellBuild.new()`, `b.add_part("stachel", Vector2(-1, 0))`, `b.add_part("geissel", Vector2(0, 1))`, `var tips := WeaponRules.spike_tips(Vector2.ZERO, 0.0, 10.0, b)` → `tips.size()` ist 1, `tips[0].is_equal_approx(Vector2(-16, 0))` wahr
- `test_spitze_gedreht`: derselbe Aufbau, `WeaponRules.spike_tips(Vector2.ZERO, PI, 10.0, b)[0].is_equal_approx(Vector2(16, 0))` wahr
- `test_lage_normalisiert`: Stachel bei (0, 0.5) → `spike_tips(Vector2.ZERO, 0.0, 10.0, b)[0].is_equal_approx(Vector2(0, 16))` wahr
- `test_treffer`: mit den Spitzen aus `test_spitzen`: `WeaponRules.spike_hits(tips, Vector2(-20, 0), 5.0)` ist 1; `spike_hits(tips, Vector2(20, 0), 5.0)` ist 0

Review (16.10.2026): gemergt.
