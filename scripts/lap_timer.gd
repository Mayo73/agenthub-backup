class_name LapTimer
extends RefCounted

## Rundenzeit-Messung für Drift-Spiel
var track_length: float
var lap := 0
var current_time := 0.0
var last_lap_time := -1.0
var best_lap_time := -1.0
var _prev_progress := -1.0
var _half_passed := false

signal lap_completed(lap_number: int, time: float, is_best: bool)


func _init(length: float = 1000.0) -> void:
	track_length = length


func update(delta: float, progress: float) -> void:
	current_time += delta

	if progress >= 0.4 * track_length and progress <= 0.6 * track_length:
		_half_passed = true

	var prev_was_close_to_finish := _prev_progress > 0.75 * track_length

	if prev_was_close_to_finish and progress < 0.25 * track_length and _half_passed:
		lap += 1
		last_lap_time = current_time

		var was_best := false
		if best_lap_time == -1.0 or last_lap_time < best_lap_time:
			best_lap_time = last_lap_time
			was_best = true

		lap_completed.emit(lap, last_lap_time, was_best)

		current_time = 0.0
		_half_passed = false

	_prev_progress = progress


func reset() -> void:
	lap = 0
	current_time = 0.0
	last_lap_time = -1.0
	best_lap_time = -1.0
	_prev_progress = -1.0
	_half_passed = false


## Gefahrene Strecke seit dem Start über alle Runden (für die Platzierung).
## Steht man vor der ersten Rennhälfte noch hinter der Ziellinie, zählt das negativ.
func distance() -> float:
	var p := maxf(_prev_progress, 0.0)
	if not _half_passed and p > track_length * 0.5:
		p -= track_length
	return lap * track_length + p


static func format_time(seconds: float) -> String:
	if seconds < 0.0:
		return "–"

	var hunderte := roundi(seconds * 100.0)
	var total_seconds := hunderte

	var minutes := total_seconds / 6000
	var remaining := total_seconds % 6000
	var sekunden := remaining / 100
	var hundertstel := remaining % 100

	return "%d:%02d.%02d" % [minutes, sekunden, hundertstel]
