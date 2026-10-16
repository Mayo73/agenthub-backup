class_name FpsMeter
extends RefCounted
## Zählt Bilder und Zeit für den Leistungstest.

var frames := 0
var elapsed := 0.0
var _min_fps := INF


## Ein Bild mit der Dauer delta in Sekunden; delta <= 0 wird übergangen.
func add_frame(delta: float) -> void:
	if delta <= 0.0:
		return
	frames += 1
	elapsed += delta
	_min_fps = minf(_min_fps, 1.0 / delta)


## Bilder pro Sekunde im Durchschnitt (frames / elapsed); 0 ohne Messung.
func average_fps() -> float:
	if elapsed <= 0.0:
		return 0.0
	return frames / elapsed


## Bildrate des langsamsten Bildes; 0 ohne Messung.
func min_fps() -> float:
	if frames == 0:
		return 0.0
	return _min_fps


func reset() -> void:
	frames = 0
	elapsed = 0.0
	_min_fps = INF
