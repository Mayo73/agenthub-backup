---
id: T-0111
title: Giftwolken (PoisonClouds) und Giftschaden
project: zellenphase
priority: 3
---
## Ziel
Eine Zelle mit Giftdrüse lässt beim Schwimmen Giftwolken hinter sich. Wer darin schwimmt, verliert Lebenspunkte, auch während der kurzen Unverwundbarkeit nach einem Biss.

## Dateien
- `scripts/poison_clouds.gd`: neu
- `scripts/cell_health.gd`
- `tests/test_poison_clouds.gd`: neu
- `tests/test_cell_health.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `scripts/poison_clouds.gd` genau so:
```gdscript
class_name PoisonClouds
extends RefCounted
## Giftwolken, die eine Zelle mit Giftdrüse hinter sich lässt. Wer darin schwimmt, verliert Lebenspunkte.

const LIFETIME := 3.0
const RADIUS := 20.0
## Schaden pro Sekunde und Wolke
const DPS := 12.0
## Mindestabstand in Sekunden zwischen zwei neuen Wolken
const INTERVAL := 0.4

## Jede Wolke: {"pos": Vector2, "age": float}
var clouds: Array[Dictionary] = []
var cooldown := 0.0


func tick(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	var kept: Array[Dictionary] = []
	for c in clouds:
		c["age"] += delta
		if c["age"] < LIFETIME:
			kept.append(c)
	clouds = kept


## Legt eine Wolke bei pos an, wenn seit der letzten genug Zeit vergangen ist.
func emit(pos: Vector2) -> bool:
	if cooldown > 0.0:
		return false
	clouds.append({"pos": pos, "age": 0.0})
	cooldown = INTERVAL
	return true


## Schaden für einen Kreis um pos mit radius in einem Zeitschritt delta.
func damage_at(pos: Vector2, radius: float, delta: float) -> float:
	var n := 0
	for c in clouds:
		if pos.distance_to(c["pos"]) <= radius + RADIUS:
			n += 1
	return DPS * delta * n
```
- `scripts/cell_health.gd`: neue Funktion am Ende:
```gdscript
## Schaden ohne Unverwundbarkeit, z. B. durch Gift. Unterbricht die Heilung.
func drain(amount: float) -> void:
	if amount <= 0.0 or is_dead():
		return
	hp = maxf(0.0, hp - amount)
	_since_hit = 0.0
```

## Tests
- `tests/test_poison_clouds.gd` mit `extends "res://tests/base_test.gd"`, `var p: PoisonClouds`, `setup()`: `p = PoisonClouds.new()`.
  - `test_ausstossen`: `p.emit(Vector2.ZERO)` wahr; sofort `p.emit(Vector2(5, 0))` falsch; `p.tick(0.5)`; `p.emit(Vector2(50, 0))` wahr; `p.clouds.size()` ist 2
  - `test_schaden`: `p.emit(Vector2.ZERO)`, `p.tick(0.5)`, `p.emit(Vector2(50, 0))` → `p.damage_at(Vector2(10, 0), 5.0, 1.0)` ist 12.0; `p.damage_at(Vector2(200, 0), 5.0, 1.0)` ist 0.0
  - `test_verfliegen`: `p.emit(Vector2.ZERO)`, `p.tick(0.5)`, `p.emit(Vector2(50, 0))`, `p.tick(2.6)` → `p.clouds.size()` ist 1; `p.tick(0.5)` → `p.clouds.size()` ist 0
- `tests/test_cell_health.gd`, neue Methode `test_gift_entzug`: `h.damage(10.0)` (jetzt unverwundbar), `h.drain(5.0)` → `h.hp` ist 85.0; `h.drain(-3.0)` → `h.hp` bleibt 85.0; `h.drain(200.0)` → `h.hp` ist 0.0 und `h.is_dead()` wahr

Review (16.10.2026): gemergt.
