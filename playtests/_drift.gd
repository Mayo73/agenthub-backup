extends Playtest
## Gemeinsame Hilfen der Drift-Spieltests: Rennszene laden und das Spielerauto über die echten
## Eingabeaktionen fahren, wie ein Spieler. Gelenkt wird nach der Logik des KI-Fahrers (AiDriver).

const RACE_SCENE := "res://scenes/main.tscn"
const LOOK_AHEAD := 260.0
const STEER_GAIN := 2.5

## Autopilot an: fährt der Mittellinie nach. Mit drift_in_curves zieht er in engen Kurven die Handbremse.
var autopilot := false
var drift_in_curves := false
var skill := 0.95
## Höchsttempo, seit der Autopilot fährt (px/s).
var top_speed := 0.0
var _sent := {}
var _measure_left := 1.0


func _init() -> void:
	scene_path = RACE_SCENE


## Wartet das Ende des Countdowns ab.
func wait_for_start() -> bool:
	return await until(func() -> bool: return scene.race.can_drive(), 6.0, "Countdown endet und das Rennen startet")


func _physics_process(delta: float) -> void:
	if not autopilot or scene == null or not is_instance_valid(scene) or not scene.race.can_drive():
		return
	var p: CarPhysics = scene.car.physics
	var path: TrackPath = scene.track.path
	var target := path.point_at(path.progress_at(p.position) + LOOK_AHEAD)
	var diff := wrapf((target - p.position).angle() - p.heading, -PI, PI)
	var steer := clampf(diff * STEER_GAIN, -1.0, 1.0)
	var cap := p.max_speed * skill * (1.0 - clampf(absf(diff) * 0.9, 0.0, 0.6))
	_set_action("gas", skill if p.speed() < cap else 0.0)
	_set_action("bremse", 0.5 if p.speed() > cap + 120.0 else 0.0)
	_set_action("rechts", maxf(steer, 0.0))
	_set_action("links", maxf(-steer, 0.0))
	var drift := drift_in_curves and absf(diff) > 0.3 and p.speed() > p.max_speed * 0.45
	_set_action("handbremse", 1.0 if drift else 0.0)
	top_speed = maxf(top_speed, p.speed())
	_measure_left -= delta
	if _measure_left <= 0.0:
		_measure_left = 1.0
		measure("tempo", roundi(p.speed()))


## Autopilot aus und alle Eingaben loslassen.
func stop_driving() -> void:
	autopilot = false
	for action in _sent.keys():
		release(action)
	_sent.clear()


func _set_action(action: String, strength: float) -> void:
	var old: float = _sent.get(action, 0.0)
	if is_equal_approx(old, strength):
		return
	_sent[action] = strength
	if strength > 0.0:
		press(action, strength)
	else:
		release(action)
