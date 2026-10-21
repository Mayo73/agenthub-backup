class_name PathFollower2D
extends RefCounted
## Bewegung entlang eines Pfads: einmal ("once"), im Kreis ("loop") oder hin
## und her ("pingpong"). step(dt) rückt um speed * dt weiter.

var points: Array[Vector2] = []
var speed := 1.0
var mode := "once"
var position := Vector2.ZERO
var target := 1
var direction := 1
var finished := false


func _init(path: Array[Vector2] = [], move_speed: float = 1.0, follow_mode: String = "once") -> void:
	points = path.duplicate()
	speed = move_speed
	mode = follow_mode
	if not points.is_empty():
		position = points[0]
	if points.size() < 2:
		finished = true


func step(dt: float) -> Vector2:
	var rest: float = speed * dt
	# Schutz gegen Endlosschleifen, wenn alle Punkte zusammenfallen.
	var guard := 0
	while rest > 0.0 and not finished and guard < points.size() * 4 + 4:
		var goal: Vector2 = points[target]
		var d: float = position.distance_to(goal)
		if rest < d:
			position = position.move_toward(goal, rest)
			rest = 0.0
		else:
			position = goal
			rest -= d
			guard = guard + 1 if d == 0.0 else 0
			_next_target()
	return position


func _next_target() -> void:
	match mode:
		"loop":
			target = (target + 1) % points.size()
		"pingpong":
			target += direction
			if target < 0 or target >= points.size():
				direction = -direction
				target += 2 * direction
		_:
			target += 1
			if target >= points.size():
				finished = true
