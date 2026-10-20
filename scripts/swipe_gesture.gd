extends RefCounted
class_name SwipeGesture

## Mindeststrecke in x (Pixel)
const THRESHOLD := 160.0

## Größte Neigung der Karte in Radiant
const MAX_TILT := 0.25

enum Result { NONE, LIKE, PASS }

var active := false
var start := Vector2.ZERO
var offset := Vector2.ZERO


func begin(pos: Vector2) -> void:
	active = true
	start = pos
	offset = Vector2.ZERO


func move(pos: Vector2) -> void:
	if not active:
		return
	offset = pos - start


func finish() -> int:
	if not active:
		return Result.NONE

	var result := Result.NONE

	if offset.x >= THRESHOLD and absf(offset.x) > absf(offset.y):
		result = Result.LIKE
	elif offset.x <= -THRESHOLD and absf(offset.x) > absf(offset.y):
		result = Result.PASS
	else:
		result = Result.NONE

	active = false
	offset = Vector2.ZERO

	return result


func cancel() -> void:
	active = false
	offset = Vector2.ZERO


func tilt() -> float:
	var normalized := offset.x / (THRESHOLD * 2.0)
	return clampf(normalized, -1.0, 1.0) * MAX_TILT


func preview() -> int:
	if not active:
		return Result.NONE

	if offset.x >= THRESHOLD and absf(offset.x) > absf(offset.y):
		return Result.LIKE
	elif offset.x <= -THRESHOLD and absf(offset.x) > absf(offset.y):
		return Result.PASS
	else:
		return Result.NONE


## Wie deutlich der Stempel auf der Karte erscheint: 0 ohne Wischen, 1 ab der Mindeststrecke.
func stamp_strength() -> float:
	if not active:
		return 0.0
	return clampf(absf(offset.x) / THRESHOLD, 0.0, 1.0)


## Welcher Stempel gilt: LIKE nach rechts, PASS nach links, NONE ohne Bewegung in x.
func stamp_kind() -> int:
	if not active or offset.x == 0.0:
		return Result.NONE
	if offset.x > 0.0:
		return Result.LIKE
	return Result.PASS