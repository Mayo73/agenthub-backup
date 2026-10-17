---
id: T-0091
title: Gesundheit und Rückstoß (CellHealth, knockback)
project: zellenphase
priority: 4
after: T-0080
---
## Ziel
Zellen haben Lebenspunkte. Nach einem Treffer sind sie kurz unverwundbar, nach einer Pause ohne Treffer heilen sie langsam. Ein Treffer stößt die Zelle zurück.

## Dateien
- `scripts/cell_health.gd`: neu
- `scripts/cell_motion.gd`: neue Funktion am Ende
- `tests/test_cell_health.gd`: neu
- `tests/test_cell_motion.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `scripts/cell_health.gd` genau so:
```gdscript
class_name CellHealth
extends RefCounted
## Lebenspunkte einer Zelle mit kurzer Unverwundbarkeit nach Treffern und langsamer Heilung.

## Sekunden Unverwundbarkeit nach einem Treffer
const HIT_COOLDOWN := 0.6
## Sekunden ohne Treffer, bevor die Heilung einsetzt
const REGEN_DELAY := 4.0

var max_hp := 100.0
var hp := 100.0
## Heilung in Lebenspunkten pro Sekunde
var regen_rate := 3.0
var invulnerable := 0.0
var _since_hit := 999.0


func _init(p_max_hp: float = 100.0) -> void:
	max_hp = p_max_hp
	hp = p_max_hp


## Zieht Lebenspunkte ab. false, wenn der Treffer nicht zählt (unverwundbar, tot oder amount <= 0).
func damage(amount: float) -> bool:
	if amount <= 0.0 or invulnerable > 0.0 or is_dead():
		return false
	hp = maxf(0.0, hp - amount)
	invulnerable = HIT_COOLDOWN
	_since_hit = 0.0
	return true


func tick(delta: float) -> void:
	invulnerable = maxf(0.0, invulnerable - delta)
	_since_hit += delta
	if not is_dead() and _since_hit >= REGEN_DELAY:
		hp = minf(max_hp, hp + regen_rate * delta)


func heal(amount: float) -> void:
	if not is_dead():
		hp = minf(max_hp, hp + amount)


func is_dead() -> bool:
	return hp <= 0.0


func ratio() -> float:
	return hp / max_hp


## Volle Gesundheit, optional mit Unverwundbarkeit in Sekunden (z. B. nach dem Wiedereinstieg).
func reset(p_invulnerable: float = 0.0) -> void:
	hp = max_hp
	invulnerable = p_invulnerable
	_since_hit = 999.0
```
- `scripts/cell_motion.gd`, neue Funktion am Ende:
```gdscript
## Stößt die Zelle in Richtung direction (wird normalisiert) mit strength Pixeln pro Sekunde an.
func knockback(direction: Vector2, strength: float) -> void:
	if direction == Vector2.ZERO:
		return
	velocity += direction.normalized() * strength
```

## Tests
- `tests/test_cell_health.gd` mit `extends "res://tests/base_test.gd"`, `var h: CellHealth`, `setup()`: `h = CellHealth.new()`.
  - `test_treffer`: `h.damage(30.0)` wahr, `h.hp` ist 70.0; sofort `h.damage(30.0)` falsch, `h.hp` 70.0; `h.tick(0.7)`; `h.damage(30.0)` wahr, `h.hp` 40.0
  - `test_tod`: `h.damage(150.0)` → `h.hp` ist 0.0, `h.is_dead()` wahr; `h.heal(10.0)` → `h.hp` bleibt 0.0
  - `test_heilung`: `h.damage(50.0)`, `h.tick(1.0)` → `h.hp` 50.0; `h.tick(3.0)` → `h.hp` 59.0; `h.ratio()` ist 0.59
  - `test_zuruecksetzen`: `h.damage(50.0)`, `h.reset(2.0)` → `h.hp` 100.0, `h.invulnerable` 2.0, `h.damage(10.0)` falsch
  - `test_eigene_lebenspunkte`: `CellHealth.new(40.0).hp` ist 40.0
- `tests/test_cell_motion.gd`, neue Methode `test_rueckstoss`: `m.knockback(Vector2(0, 2), 100.0)` → `m.velocity` ist (0, 100); `m.knockback(Vector2.ZERO, 100.0)` → `m.velocity` bleibt (0, 100)

Review (16.10.2026): gemergt.
