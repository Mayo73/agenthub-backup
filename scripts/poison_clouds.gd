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
