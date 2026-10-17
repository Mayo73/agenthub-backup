---
id: T-0241
title: Fischphase – Schwimmen in drei Raumachsen (FishMotion)
project: zellenphase
priority: 3
---
## Ziel
In der Fischphase schwimmt der Fisch frei in allen drei Raumachsen: Schub nach vorn, Drehen nach links und rechts, Auf- und Abtauchen durch Neigen. Er bleibt unter der Oberfläche und über dem Boden. Siehe Abschnitt „Fischphase (3D)“ in `CLAUDE.md` (Blickrichtung -z bei yaw = 0).

## Dateien
- `scripts/fish_motion.gd` – neu
- `tests/test_fish_motion.gd` – neu

## Akzeptanzkriterien
`scripts/fish_motion.gd` genau so:
```gdscript
class_name FishMotion
extends RefCounted
## Schwimmen in drei Raumachsen: Schub nach vorn, Drehen (yaw) und Neigen (pitch) zum Auf- und Abtauchen.
## Bei yaw = 0 und pitch = 0 schwimmt der Fisch nach -z. Positives yaw dreht nach links, positives pitch nach oben.

## Größte Neigung (etwa 70 Grad).
const MAX_PITCH := 1.2

var position := FishWorld.START
var velocity := Vector3.ZERO
var yaw := 0.0
var pitch := 0.0
## Höchsttempo in m/s
var max_speed := 8.0
## Beschleunigung bei vollem Schub in m/s²
var accel := 10.0
## Drehgeschwindigkeit in rad/s
var turn_rate := 1.8
## Neigegeschwindigkeit in rad/s
var pitch_rate := 1.4
## Wasserwiderstand pro Sekunde
var drag := 1.5


## Blickrichtung als Einheitsvektor.
static func forward_of(p_yaw: float, p_pitch: float) -> Vector3:
	return Vector3(-sin(p_yaw) * cos(p_pitch), sin(p_pitch), -cos(p_yaw) * cos(p_pitch))


func forward() -> Vector3:
	return forward_of(yaw, pitch)


## Ein Schritt. thrust: 1 = voller Schub vorwärts, negativ rückwärts (höchstens -0.5).
## turn: 1 = links, -1 = rechts. climb: 1 = auftauchen, -1 = abtauchen, 0 = waagrecht ausrichten.
func step(thrust: float, turn: float, climb: float, delta: float) -> void:
	yaw = wrapf(yaw + clampf(turn, -1.0, 1.0) * turn_rate * delta, -PI, PI)
	pitch = move_toward(pitch, clampf(climb, -1.0, 1.0) * MAX_PITCH, pitch_rate * delta)
	velocity += forward() * clampf(thrust, -0.5, 1.0) * accel * delta
	velocity -= velocity * minf(drag * delta, 1.0)
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	var wanted := position + velocity * delta
	position = FishWorld.clamp_to_water(wanted)
	if position.x != wanted.x:
		velocity.x = 0.0
	if position.y != wanted.y:
		velocity.y = 0.0
	if position.z != wanted.z:
		velocity.z = 0.0


func speed() -> float:
	return velocity.length()


## Tiefe unter der Oberfläche in Metern.
func depth() -> float:
	return FishWorld.depth_of(position)
```
- Keine andere Datei ändern.

## Tests
`tests/test_fish_motion.gd` mit `extends "res://tests/base_test.gd"`, `var m: FishMotion`; `setup()`: `m = FishMotion.new()`:
- `test_vorne`: `FishMotion.forward_of(0.0, 0.0).is_equal_approx(Vector3(0, 0, -1))` wahr; `FishMotion.forward_of(PI / 2.0, 0.0).is_equal_approx(Vector3(-1, 0, 0))` wahr; `FishMotion.forward_of(0.0, PI / 2.0).is_equal_approx(Vector3(0, 1, 0))` wahr
- `test_start`: `m.position` ist `FishWorld.START`; `m.depth()` ist 20.0; `m.speed()` ist 0.0
- `test_schub`: `m.step(1.0, 0.0, 0.0, 0.1)` → `m.velocity.z` ist -0.85; `m.position.z` ist -0.085; `m.position.y` ist -20.0
- `test_hoechsttempo`: 200-mal `m.step(1.0, 0.0, 0.0, 0.1)` → `m.speed() <= m.max_speed + 0.001` wahr; `m.speed() > 5.0` wahr
- `test_drehen`: `m.step(0.0, 1.0, 0.0, 0.5)` → `m.yaw` ist 0.9; `m.step(0.0, -1.0, 0.0, 1.0)` → `m.yaw` ist -0.9
- `test_auftauchen`: zehnmal `m.step(0.0, 0.0, 1.0, 0.1)` → `m.pitch` ist `FishMotion.MAX_PITCH`; danach 50-mal `m.step(1.0, 0.0, 1.0, 0.1)` → `m.position.y > -15.0` wahr
- `test_abtauchen`: 60-mal `m.step(1.0, 0.0, -1.0, 0.1)` → `m.position.y < -25.0` wahr
- `test_ausrichten`: `m.pitch = 1.0`; `m.step(0.0, 0.0, 0.0, 0.5)` → `m.pitch` ist 0.3
- `test_oberflaeche`: `m.position = Vector3(0, -1, 0)`; `m.velocity = Vector3(0, 5, 0)`; `m.drag = 0.0`; `m.step(0.0, 0.0, 0.0, 1.0)` → `m.position.y` ist -0.5; `m.velocity.y` ist 0.0
- `test_boden`: `m.position = Vector3(0, -59, 0)`; `m.velocity = Vector3(0, -6, 0)`; `m.drag = 0.0`; `m.step(0.0, 0.0, 0.0, 1.0)` → `m.position.y` ist `-FishWorld.DEPTH + 0.5`; `m.velocity.y` ist 0.0

Review (17.10.2026): gemergt.
