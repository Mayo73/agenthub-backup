---
id: T-0095
title: Verteilung der KI-Zellen (EcoSpawner)
project: zellenphase
priority: 3
after: T-0092
---
## Ziel
Rund um die Spielerzelle sollen immer etwa 30 andere Zellen leben, passend zur aktuellen Größe: Arten aus dem eigenen und den benachbarten Größenabschnitten. Neue Zellen erscheinen außerhalb des Bildes, weit entfernte verschwinden. Abstände wachsen mit der Zellgröße mit, weil die Kamera herauszoomt.

## Dateien
- `scripts/eco_spawner.gd`: neu
- `tests/test_eco_spawner.gd`: neu

## Akzeptanzkriterien
`scripts/eco_spawner.gd` genau so:
```gdscript
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
```

## Tests
`tests/test_eco_spawner.gd` mit `extends "res://tests/base_test.gd"`:
- `test_arten_passend`: `EcoSpawner.new(3)`, 200-mal `pick_species(0)` → jede gezogene ID steckt in `SpeciesCatalog.ids_near_stage(0)`, und alle drei IDs daraus kommen mindestens einmal vor
- `test_grosse_zelle`: 100-mal `pick_species(4)` → nie `"blasenling"`
- `test_ring`: 50-mal `spawn_position(Vector2.ZERO, 1.0)` → Abstand zum Ursprung zwischen 699.9 und 1300.1; 50-mal mit `scale` 2.0 → zwischen 1399.9 und 2600.1
- `test_fehlende`: `EcoSpawner.missing(10)` ist 20, `missing(40)` ist 0
- `test_massstab`: `EcoSpawner.view_scale(24.0)` ist 2.0; `is_too_far(Vector2.ZERO, Vector2(1900, 0), 1.0)` wahr; `is_too_far(Vector2.ZERO, Vector2(1700, 0), 1.0)` falsch

Review (16.10.2026): gemergt.
