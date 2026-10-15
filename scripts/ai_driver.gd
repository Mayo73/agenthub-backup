class_name AiDriver
extends RefCounted

const LOOK_AHEAD := 260.0
const STEER_GAIN := 2.5

var skill := 0.9

## Setzt Gas, Bremse und Lenkung so, dass das Auto der Mittellinie von `path` folgt.
func drive(physics: CarPhysics, path: TrackPath) -> void:
	var pos := physics.position
	var target := path.point_at(path.progress_at(pos) + LOOK_AHEAD)
	var diff := wrapf((target - pos).angle() - physics.heading, -PI, PI)
	physics.steer = clampf(diff * STEER_GAIN, -1.0, 1.0)
	var speed_cap: float = physics.max_speed * skill * (1.0 - clampf(absf(diff) * 0.9, 0.0, 0.6))
	physics.throttle = skill if physics.speed() < speed_cap else 0.0
	physics.brake = 0.5 if physics.speed() > speed_cap + 120.0 else 0.0
	physics.handbrake = false
