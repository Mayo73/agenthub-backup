extends RefCounted
class_name Ballistics

const GRAVITY := 9.81
const HZ := 120

## Berechnet die Position zu einem Zeitpunkt t für eine 2D-Flugbahn.
## start: Startposition
## velocity: Anfangsgeschwindigkeit
## t: Zeitraum seit Start
## gravity: Schwerkraft (Standard: GRAVITY)
static func position_2d(start: Vector2, velocity: Vector2, t: float, gravity: float = GRAVITY) -> Vector2:
	return start + velocity * t + Vector2(0, gravity) * 0.5 * t * t

## Berechnet die Position zu einem Zeitpunkt t für eine 3D-Flugbahn.
## start: Startposition
## velocity: Anfangsgeschwindigkeit
## t: Zeitraum seit Start
## gravity: Schwerkraft (Standard: GRAVITY)
static func position_3d(start: Vector3, velocity: Vector3, t: float, gravity: float = GRAVITY) -> Vector3:
	return start + velocity * t + Vector3(0, -gravity, 0) * 0.5 * t * t

## Simuliert eine 2D-Flugbahn und gibt alle Punkte zurück.
## start: Startposition
## velocity: Anfangsgeschwindigkeit
## duration: Gesamtdauer der Simulation
## hz: Schritte pro Sekunde (Standard: HZ)
## gravity: Schwerkraft (Standard: GRAVITY)
static func simulate_2d(start: Vector2, velocity: Vector2, duration: float, hz: int = HZ, gravity: float = GRAVITY) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	points.append(start)

	var steps: int = roundi(duration * hz)
	var dt: float = 1.0 / hz
	var a: Vector2 = Vector2(0, gravity)

	var v: Vector2 = velocity
	var p: Vector2 = start

	for i in range(steps):
		p += v * dt + a * 0.5 * dt * dt
		v += a * dt
		points.append(p)

	return points

## Simuliert eine 3D-Flugbahn und gibt alle Punkte zurück.
## start: Startposition
## velocity: Anfangsgeschwindigkeit
## duration: Gesamtdauer der Simulation
## hz: Schritte pro Sekunde (Standard: HZ)
## gravity: Schwerkraft (Standard: GRAVITY)
static func simulate_3d(start: Vector3, velocity: Vector3, duration: float, hz: int = HZ, gravity: float = GRAVITY) -> PackedVector3Array:
	var points: PackedVector3Array = PackedVector3Array()
	points.append(start)

	var steps: int = roundi(duration * hz)
	var dt: float = 1.0 / hz
	var a: Vector3 = Vector3(0, -gravity, 0)

	var v: Vector3 = velocity
	var p: Vector3 = start

	for i in range(steps):
		p += v * dt + a * 0.5 * dt * dt
		v += a * dt
		points.append(p)

	return points

## Berechnet den maximalen Fehler zwischen simulierten Punkten und der analytischen Lösung (2D).
## points: Simulierte Punkte
## start: Startposition
## velocity: Anfangsgeschwindigkeit
## hz: Schritte pro Sekunde (Standard: HZ)
## gravity: Schwerkraft (Standard: GRAVITY)
static func max_error_2d(points: PackedVector2Array, start: Vector2, velocity: Vector2, hz: int = HZ, gravity: float = GRAVITY) -> float:
	var max_err: float = 0.0

	for i in range(points.size()):
		var t: float = float(i) / float(hz)
		var analytic_pos: Vector2 = position_2d(start, velocity, t, gravity)
		var err: float = (points[i] - analytic_pos).length()
		if err > max_err:
			max_err = err

	return max_err

## Berechnet den maximalen Fehler zwischen simulierten Punkten und der analytischen Lösung (3D).
## points: Simulierte Punkte
## start: Startposition
## velocity: Anfangsgeschwindigkeit
## hz: Schritte pro Sekunde (Standard: HZ)
## gravity: Schwerkraft (Standard: GRAVITY)
static func max_error_3d(points: PackedVector3Array, start: Vector3, velocity: Vector3, hz: int = HZ, gravity: float = GRAVITY) -> float:
	var max_err: float = 0.0

	for i in range(points.size()):
		var t: float = float(i) / float(hz)
		var analytic_pos: Vector3 = position_3d(start, velocity, t, gravity)
		var err: float = (points[i] - analytic_pos).length()
		if err > max_err:
			max_err = err

	return max_err

## Berechnet den Zeitpunkt, an dem eine 2D-Flugbahn eine bestimmte Höhe erreicht.
## start_y: Start-y-Koordinate
## velocity_y: Anfangsgeschwindigkeit in y-Richtung
## target_y: Ziel-höhe
## gravity: Schwerkraft (Standard: GRAVITY)
## Zurück: größerer t >= 0, an dem y(t) = target_y ist; -1.0 wenn keine Lösung existiert
static func time_to_height_2d(start_y: float, velocity_y: float, target_y: float, gravity: float = GRAVITY) -> float:
	## y(t) = start_y + velocity_y * t + 0.5 * gravity * t^2 = target_y
	## => 0.5 * gravity * t^2 + velocity_y * t + (start_y - target_y) = 0
	## Quadratische Gleichung: a * t^2 + b * t + c = 0

	var a: float = 0.5 * gravity
	var b: float = velocity_y
	var c: float = start_y - target_y

	var delta: float = b * b - 4 * a * c

	if delta < 0:
		return -1.0

	var sqrt_delta: float = sqrt(delta)
	var t1: float = (-b + sqrt_delta) / (2 * a)
	var t2: float = (-b - sqrt_delta) / (2 * a)

	## Wir wollen die größere Lösung mit t >= 0
	if t1 >= 0 and t2 >= 0:
		return max(t1, t2)
	elif t1 >= 0:
		return t1
	elif t2 >= 0:
		return t2
	else:
		return -1.0
