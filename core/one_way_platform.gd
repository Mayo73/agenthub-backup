class_name OneWayPlatform
extends RefCounted

## Statische Funktionen für durchspringbare Plattformen.
## y wächst nach unten (wie in Godot 2D).


static func blocks(vel_y: float, prev_foot_y: float, foot_y: float, top_y: float, drop: bool = false) -> bool:
	if drop:
		return false
	if vel_y < 0.0:
		return false
	if prev_foot_y > top_y + 0.01:
		return false
	if foot_y < top_y:
		return false
	return true


static func in_span(x: float, x_min: float, x_max: float) -> bool:
	return x_min <= x and x <= x_max


static func land(foot_y: float, top_y: float) -> float:
	return minf(foot_y, top_y)
