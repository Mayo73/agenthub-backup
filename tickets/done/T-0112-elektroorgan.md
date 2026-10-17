---
id: T-0112
title: Elektrische Abwehr (ElectricOrgan)
project: zellenphase
priority: 3
---
## Ziel
Das Elektroorgan entlädt sich, sobald ein Gegner nah genug ist, verletzt ihn und muss dann nachladen.

## Dateien
- `scripts/electric_organ.gd`: neu
- `tests/test_electric_organ.gd`: neu

## Akzeptanzkriterien
`scripts/electric_organ.gd` genau so:
```gdscript
class_name ElectricOrgan
extends RefCounted
## Elektrische Abwehr: entlädt sich, wenn ein Gegner nah genug ist, und lädt dann nach.

const DAMAGE := 18.0
const COOLDOWN := 1.5
## Reichweite in Zellradien, von der Zellmitte gemessen
const RANGE := 1.6
## Wie lange der Blitz nach einer Entladung sichtbar bleibt
const FLASH_TIME := 0.2

var charge_time := 0.0
var flash := 0.0


func tick(delta: float) -> void:
	charge_time = maxf(0.0, charge_time - delta)
	flash = maxf(0.0, flash - delta)


func is_ready() -> bool:
	return charge_time <= 0.0


func fire() -> void:
	charge_time = COOLDOWN
	flash = FLASH_TIME


static func in_range(center: Vector2, radius: float, target_pos: Vector2, target_radius: float) -> bool:
	return center.distance_to(target_pos) <= radius * RANGE + target_radius
```

## Tests
`tests/test_electric_organ.gd` mit `extends "res://tests/base_test.gd"`, `var e: ElectricOrgan`, `setup()`: `e = ElectricOrgan.new()`.
- `test_bereit`: `e.is_ready()` wahr; `e.fire()` → `e.is_ready()` falsch, `e.flash` ist 0.2
- `test_nachladen`: `e.fire()`, `e.tick(1.0)` → `e.is_ready()` falsch; `e.tick(0.5)` → `e.is_ready()` wahr, `e.flash` ist 0.0
- `test_reichweite`: `ElectricOrgan.in_range(Vector2.ZERO, 10.0, Vector2(25, 0), 10.0)` wahr; `in_range(Vector2.ZERO, 10.0, Vector2(27, 0), 10.0)` falsch

Review (16.10.2026): gemergt.
