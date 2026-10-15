extends RefCounted
class_name GhostLap

const SAMPLE_INTERVAL := 0.05

var times := PackedFloat32Array()
var positions := PackedVector2Array()
var headings := PackedFloat32Array()


func record(time: float, position: Vector2, heading: float) -> void:
	if times.is_empty():
		times.append(time)
		positions.append(position)
		headings.append(heading)
	elif time - times[times.size() - 1] >= SAMPLE_INTERVAL - 0.0001:
		times.append(time)
		positions.append(position)
		headings.append(heading)


func sample_count() -> int:
	return times.size()


func duration() -> float:
	if times.is_empty():
		return 0.0
	return times[times.size() - 1]


func is_empty() -> bool:
	return times.is_empty()
