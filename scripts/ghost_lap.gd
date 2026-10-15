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


func position_at(time: float) -> Vector2:
	if times.is_empty():
		return Vector2.ZERO
	if time <= times[0]:
		return positions[0]
	if time >= duration():
		return positions[times.size() - 1]
	for i in range(times.size() - 1):
		if times[i] <= time and time < times[i + 1]:
			var t := (time - times[i]) / (times[i + 1] - times[i])
			return positions[i].lerp(positions[i + 1], t)
	return positions[times.size() - 1]


func heading_at(time: float) -> float:
	if times.is_empty():
		return 0.0
	if time <= times[0]:
		return headings[0]
	if time >= duration():
		return headings[times.size() - 1]
	for i in range(times.size() - 1):
		if times[i] <= time and time < times[i + 1]:
			var t := (time - times[i]) / (times[i + 1] - times[i])
			return lerp_angle(headings[i], headings[i + 1], t)
	return headings[times.size() - 1]
