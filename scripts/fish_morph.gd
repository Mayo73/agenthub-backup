extends RefCounted
class_name FishMorph

const DURATION := 2.5
const FADE := 0.8

var time := 0.0
var running := false

func start() -> void:
	time = 0.0
	running = true

func tick(delta: float) -> void:
	if not running:
		return
	time += delta
	if time >= DURATION + FADE:
		running = false

func morph() -> float:
	return smoothstep(0.0, 1.0, clampf(time / DURATION, 0.0, 1.0))

func stretch() -> float:
	return lerpf(1.0, 2.2, morph())

func tail() -> float:
	return lerpf(0.0, 0.9, morph())

func fade() -> float:
	return clampf((time - DURATION) / FADE, 0.0, 1.0)

func is_done() -> bool:
	return time >= DURATION + FADE
