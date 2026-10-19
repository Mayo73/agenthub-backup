class_name Bounce
extends RefCounted
## Physik-Rückprall am Boden für 2D und 3D.
## Alle Funktionen sind statisch, keine Instanzen nötig.

const GRAVITY := 9.81
const HZ := 120
const REST_SPEED := 0.05


## Simulation eines Körpers mit Schwerkraft und Rückprall am Boden (2D).
## @param start Startposition
## @param velocity Startgeschwindigkeit
## @param floor_y Höhe des Bodens (y = floor_y)
## @param restitution Rückprallfaktor (Energieverlust)
## @param duration Simulationsdauer in Sekunden
## @param hz Schrittanzahl pro Sekunde (default: 120)
## @param gravity Schwerkraftbeschleunigung nach +y (default: 9.81)
## @return Dictionary mit "points", "bounces" und "velocity"
static func simulate_2d(start: Vector2, velocity: Vector2, floor_y: float,
	restitution: float, duration: float, hz: int = HZ,
	gravity: float = GRAVITY) -> Dictionary:
	var steps: int = roundi(duration * hz)
	var dt: float = 1.0 / float(hz)

	var p: Vector2 = start
	var v: Vector2 = velocity
	var bounces: int = 0

	var points: PackedVector2Array = PackedVector2Array()
	points.push_back(start)

	for _i in range(steps):
		v.y += gravity * dt
		p += v * dt

		if p.y > floor_y:
			p.y = floor_y
			v.y = -v.y * restitution
			bounces += 1

			if absf(v.y) < REST_SPEED:
				v.y = 0.0

		points.push_back(p)

	return {
		"points": points,
		"bounces": bounces,
		"velocity": v
	}


## Simulation eines Körpers mit Schwerkraft und Rückprall am Boden (3D).
## @param start Startposition
## @param velocity Startgeschwindigkeit
## @param floor_y Höhe des Bodens (y = floor_y)
## @param restitution Rückprallfaktor (Energieverlust)
## @param duration Simulationsdauer in Sekunden
## @param hz Schrittanzahl pro Sekunde (default: 120)
## @param gravity Schwerkraftbeschleunigung nach -y (default: 9.81)
## @return Dictionary mit "points", "bounces" und "velocity"
static func simulate_3d(start: Vector3, velocity: Vector3, floor_y: float,
	restitution: float, duration: float, hz: int = HZ,
	gravity: float = GRAVITY) -> Dictionary:
	var steps: int = roundi(duration * hz)
	var dt: float = 1.0 / float(hz)

	var p: Vector3 = start
	var v: Vector3 = velocity
	var bounces: int = 0

	var points: PackedVector3Array = PackedVector3Array()
	points.push_back(start)

	for _i in range(steps):
		v.y -= gravity * dt
		p += v * dt

		if p.y < floor_y:
			p.y = floor_y
			v.y = -v.y * restitution
			bounces += 1

			if absf(v.y) < REST_SPEED:
				v.y = 0.0

		points.push_back(p)

	return {
		"points": points,
		"bounces": bounces,
		"velocity": v
	}


## Ermittelt die lokalen Hochpunkte einer Bahn über dem Boden (2D).
## Ein Punkt i ist ein lokaler Hochpunkt, wenn y[i] < y[i-1] und y[i] <= y[i+1].
## Nur Höhen > 0.01 werden zurückgegeben.
## @param points Punkte der Bahn
## @param floor_y Höhe des Bodens
## @return Array mit Höhen über dem Boden an jedem lokalen Hochpunkt
static func peak_heights_2d(points: PackedVector2Array, floor_y: float) -> Array[float]:
	var peaks: Array[float] = []

	for i in range(1, points.size() - 1):
		var y_prev: float = points[i - 1].y
		var y_curr: float = points[i].y
		var y_next: float = points[i + 1].y

		if y_curr < y_prev and y_curr <= y_next:
			var height: float = floor_y - y_curr
			if height > 0.01:
				peaks.append(height)

	return peaks
