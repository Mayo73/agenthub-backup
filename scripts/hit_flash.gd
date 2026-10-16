class_name HitFlash
extends RefCounted
## Kurzes rotes Aufblitzen nach einem Treffer.

const DURATION := 0.25
const COLOR := Color(1.0, 0.25, 0.2)
const MAX_ALPHA := 0.5

var time_left := 0.0


func trigger() -> void:
	time_left = DURATION


func tick(delta: float) -> void:
	time_left = maxf(0.0, time_left - delta)


## Stärke von 1 (gerade getroffen) bis 0 (vorbei).
func amount() -> float:
	return time_left / DURATION


func is_active() -> bool:
	return time_left > 0.0


## Farbe der Überlagerung mit passender Deckkraft.
func overlay_color() -> Color:
	var c := COLOR
	c.a = MAX_ALPHA * amount()
	return c
