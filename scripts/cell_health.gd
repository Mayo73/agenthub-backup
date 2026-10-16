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
