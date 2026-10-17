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
