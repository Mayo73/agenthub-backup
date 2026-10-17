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
