extends RefCounted
class_name AimSolver

## Abschussrichtung für ein Ziel bei fester Mündungsgeschwindigkeit unter Schwerkraft.


## Abschusswinkel (Bogenmaß über der Waagerechten), aufsteigend: flache Bahn zuerst.
## Leer, wenn das Ziel nicht erreichbar ist oder distance <= 0.
static func angles(distance: float, height: float, speed: float, gravity: float = Ballistics.GRAVITY) -> Array[float]:
	var result: Array[float] = []
	if distance <= 0.0 or gravity <= 0.0:
		return result
	var v2: float = speed * speed
	var root: float = v2 * v2 - gravity * (gravity * distance * distance + 2.0 * height * v2)
	if root < 0.0:
		return result
	var s: float = sqrt(root)
	var low: float = atan((v2 - s) / (gravity * distance))
	var high: float = atan((v2 + s) / (gravity * distance))
	result.append(low)
	if s > 0.0:
		result.append(high)
	return result


## Geschwindigkeitsvektor mit Länge speed, der to von from aus trifft; Vector3.ZERO, wenn unerreichbar.
static func direction_3d(from: Vector3, to: Vector3, speed: float, high: bool = false, gravity: float = Ballistics.GRAVITY) -> Vector3:
	var flat: Vector2 = Vector2(to.x - from.x, to.z - from.z)
	var list: Array[float] = angles(flat.length(), to.y - from.y, speed, gravity)
	if list.is_empty():
		return Vector3.ZERO
	var theta: float = list[list.size() - 1] if high else list[0]
	var dir: Vector2 = flat.normalized() * cos(theta) * speed
	return Vector3(dir.x, sin(theta) * speed, dir.y)


## Flugzeit bis zur waagerechten Entfernung distance.
static func flight_time(distance: float, angle: float, speed: float) -> float:
	return distance / (speed * cos(angle))
