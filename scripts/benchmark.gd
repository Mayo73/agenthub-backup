class_name Benchmark
extends Node
## Leistungstest: misst DURATION Sekunden lang die Bildrate und schreibt das Ergebnis in eine Datei.
## Start: Godot mit "-- --benchmark"; main.gd hängt diesen Node dann an.

signal finished(text: String)

const DURATION := 60.0
const RESULT_PATH := "user://leistungstest.txt"

var meter := FpsMeter.new()
var duration := DURATION
var result_path := RESULT_PATH
## Liefert die Zahl der aktiven KI-Zellen (wird von main.gd gesetzt).
var ai_counter: Callable
var min_ai := -1
var done := false


static func requested(args: PackedStringArray) -> bool:
	return args.has("--benchmark")


func _process(delta: float) -> void:
	step(delta)


## Ein Messschritt; nach duration Sekunden wird das Ergebnis einmal geschrieben und finished gemeldet.
func step(delta: float) -> void:
	if done:
		return
	meter.add_frame(delta)
	if ai_counter.is_valid():
		var n := int(ai_counter.call())
		min_ai = n if min_ai < 0 else mini(min_ai, n)
	if meter.elapsed >= duration:
		done = true
		var text := result_text()
		var file := FileAccess.open(result_path, FileAccess.WRITE)
		if file != null:
			file.store_string(text)
			file.close()
		finished.emit(text)


func result_text() -> String:
	return "Leistungstest: %.1f s, Durchschnitt %.1f FPS, Minimum %.1f FPS, mindestens %d KI-Zellen" % [meter.elapsed, meter.average_fps(), meter.min_fps(), maxi(min_ai, 0)]
