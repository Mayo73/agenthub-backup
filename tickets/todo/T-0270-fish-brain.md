---
id: T-0270
title: FishBrain – Verhalten und Lenken der KI-Fische
project: zellenphase
priority: 4
after: T-0269
---
## Ziel
Meilenstein „Fischphase – Leben im Meer“: KI-Fische entscheiden, wohin sie schwimmen: Raubfische jagen einen kleineren Spielerfisch, Beutefische fliehen vor einem großen, Schwarmfische halten zusammen. Außerdem wird eine Wunschrichtung in einen Schwimmbefehl für `FishMotion.step()` übersetzt.

## Dateien
- `scripts/fish_brain.gd` – neu
- `tests/test_fish_brain.gd` – neu

## Akzeptanzkriterien
Neue Datei `scripts/fish_brain.gd`, genau so:
```gdscript
class_name FishBrain
extends RefCounted
## Entscheidungen der KI-Fische und Lenken in drei Raumachsen.

## Beutefische fliehen, wenn der Spieler mindestens so groß ist (Anteil der eigenen Größe).
const FLEE_FACTOR := 0.8
## Schwarmfische bleiben innerhalb so vieler Meter um die Schwarmmitte.
const FLOCK_DIST := 3.0
## Schub ohne Ziel (gemächliches Umherschwimmen).
const CRUISE := 0.3


## Wunschrichtung (Länge 1 oder Vector3.ZERO). flock_center: Mitte des eigenen Schwarms oder null.
static func decide(behavior: String, own_pos: Vector3, own_size: float, sight: float, player_pos: Vector3, player_size: float, flock_center: Variant) -> Vector3:
	var dist := own_pos.distance_to(player_pos)
	if dist <= sight and dist > 0.001:
		if behavior == "jaeger":
			if player_size < own_size:
				return (player_pos - own_pos).normalized()
		elif player_size >= own_size * FLEE_FACTOR:
			return (own_pos - player_pos).normalized()
	if behavior == "schwarm" and flock_center is Vector3:
		var center: Vector3 = flock_center
		if own_pos.distance_to(center) > FLOCK_DIST:
			return (center - own_pos).normalized()
	return Vector3.ZERO


## Schwimmbefehl Vector3(thrust, turn, climb) für FishMotion.step(), um in Richtung dir zu schwimmen.
static func steer(motion: FishMotion, dir: Vector3) -> Vector3:
	if dir.length() < 0.001:
		return Vector3(CRUISE, 0.0, 0.0)
	var d := dir.normalized()
	var want_yaw := atan2(-d.x, -d.z)
	var want_pitch := asin(clampf(d.y, -1.0, 1.0))
	var turn := clampf(angle_difference(motion.yaw, want_yaw) * 2.0, -1.0, 1.0)
	var climb := clampf(want_pitch / FishMotion.MAX_PITCH, -1.0, 1.0)
	return Vector3(1.0, turn, climb)
```

## Tests
Neue Datei `tests/test_fish_brain.gd` (`extends "res://tests/base_test.gd"`); `P := Vector3(0, -20, 0)`:
- `test_jaeger_jagt_kleinen`: `decide("jaeger", P, 1.8, 18.0, P + Vector3(10, 0, 0), 1.0, null)` ist `Vector3(1, 0, 0)`
- `test_jaeger_meidet_grossen`: dasselbe mit Spielergröße 2.0 → `Vector3.ZERO`
- `test_ausser_sicht`: `decide("jaeger", P, 1.8, 18.0, P + Vector3(30, 0, 0), 1.0, null)` ist `Vector3.ZERO`
- `test_beute_flieht`: `decide("scheu", P, 1.0, 10.0, P + Vector3(0, 0, 5), 1.0, null)` ist `Vector3(0, 0, -1)`
- `test_beute_bleibt_bei_kleinem`: `decide("scheu", P, 1.0, 10.0, P + Vector3(0, 0, 5), 0.5, null)` ist `Vector3.ZERO`
- `test_schwarm`: `decide("schwarm", P, 0.6, 12.0, P + Vector3(100, 0, 0), 1.0, P + Vector3(0, 10, 0))` ist `Vector3(0, 1, 0)`; mit Schwarmmitte `P + Vector3(0, 2, 0)` → `Vector3.ZERO`
- `test_lenken_geradeaus`: `var m := FishMotion.new()` (yaw 0, pitch 0); `steer(m, Vector3(0, 0, -1))` ist `Vector3(1, 0, 0)` (Toleranz 0,001 je Achse)
- `test_lenken_links`: `steer(m, Vector3(-1, 0, 0)).y` ist 1.0 (links); `steer(m, Vector3(1, 0, 0)).y` ist -1.0
- `test_lenken_hoch`: `steer(m, Vector3(0, 1, 0)).z` ist 1.0; `steer(m, Vector3.ZERO)` ist `Vector3(0.3, 0, 0)`
- `test_folgt_richtung`: `m.yaw = 2.0`; 60 Schritte: `var c := FishBrain.steer(m, Vector3(0, 0, -1))`; `m.step(c.x, c.y, c.z, 0.05)` → `absf(m.yaw) < 0.2` wahr
