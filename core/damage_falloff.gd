extends RefCounted
class_name DamageFalloff

var base: float = 10.0
var near: float = 5.0
var far: float = 20.0
var min_factor: float = 0.25

func _init(p_base: float = 10.0, p_near: float = 5.0, p_far: float = 20.0, p_min_factor: float = 0.25) -> void:
	base = p_base
	near = p_near
	far = p_far
	min_factor = p_min_factor

func factor(distance: float) -> float:
	if far <= near:
		return 1.0 if distance <= near else min_factor
	var t: float = (distance - near) / (far - near)
	if distance <= near:
		return 1.0
	elif distance >= far:
		return min_factor
	else:
		return lerp(1.0, min_factor, t)

func amount(distance: float) -> float:
	return base * factor(distance)

static func splash(center: Vector3, radius: float, damage: float, positions: Array[Vector3]) -> Array[float]:
	if radius <= 0.0:
		var zeros: Array[float] = []
		for _p in positions:
			zeros.append(0.0)
		return zeros

	var result: Array[float] = []
	for p in positions:
		var d: float = center.distance_to(p)
		if d >= radius:
			result.append(0.0)
		else:
			result.append(damage * (1.0 - d / radius))
	return result
