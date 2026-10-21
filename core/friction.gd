class_name Friction
extends RefCounted
## Physik: Reibung beim Gleiten in 2D und 3D.
## Alle Funktionen sind statisch, keine Instanzen nötig.


## Kombiniert zwei Reibungskoeffizienten geometrisch.
## @param a Erster Reibungskoeffizient
## @param b Zweiter Reibungskoeffizient
## @return Geometrischer Mittelwert von a und b
static func combine(a: float, b: float) -> float:
	return sqrt(maxf(a, 0.0) * maxf(b, 0.0))


## Bremst eine Gleitgeschwindigkeit aufgrund von Reibung ab (2D).
## Der Anteil senkrecht zur Fläche bleibt unverändert.
## @param velocity Geschwindigkeit des Körpers
## @param normal Normalenvektor der Fläche
## @param mu Reibungskoeffizient
## @param gravity Schwerkraftbeschleunigung
## @param dt Zeitschritt in Sekunden
## @return Neue Geschwindigkeit nach Abbremsung
static func slide(velocity: Vector2, normal: Vector2, mu: float, gravity: float, dt: float) -> Vector2:
	var n: Vector2 = normal.normalized()

	## Senkrechter Anteil (parallel zur Normalen)
	var vn: Vector2 = n * velocity.dot(n)

	## Tangentialer Anteil (senkrecht zur Normalen, also entlang der Fläche)
	var vt: Vector2 = velocity - vn

	## Abbremsung durch Reibung
	var drop: float = mu * gravity * dt

	if vt.length() <= drop:
		vt = Vector2.ZERO
	else:
		vt -= vt.normalized() * drop

	return vn + vt


## Bremst eine Gleitgeschwindigkeit aufgrund von Reibung ab (3D).
## Der Anteil senkrecht zur Fläche bleibt unverändert.
## @param velocity Geschwindigkeit des Körpers
## @param normal Normalenvektor der Fläche
## @param mu Reibungskoeffizient
## @param gravity Schwerkraftbeschleunigung
## @param dt Zeitschritt in Sekunden
## @return Neue Geschwindigkeit nach Abbremsung
static func slide_3d(velocity: Vector3, normal: Vector3, mu: float, gravity: float, dt: float) -> Vector3:
	var n: Vector3 = normal.normalized()

	## Senkrechter Anteil (parallel zur Normalen)
	var vn: Vector3 = n * velocity.dot(n)

	## Tangentialer Anteil (senkrecht zur Normalen, also entlang der Fläche)
	var vt: Vector3 = velocity - vn

	## Abbremsung durch Reibung
	var drop: float = mu * gravity * dt

	if vt.length() <= drop:
		vt = Vector3.ZERO
	else:
		vt -= vt.normalized() * drop

	return vn + vt


## Berechnet den Bremsweg bei gegebener Anfangsgeschwindigkeit und Reibung.
## @param speed Anfangsgeschwindigkeit (Betrag)
## @param mu Reibungskoeffizient
## @param gravity Schwerkraftbeschleunigung
## @return Bremsstrecke in Einheiten, unendlich wenn mu <= 0
static func stop_distance(speed: float, mu: float, gravity: float) -> float:
	if mu * gravity <= 0.0:
		return INF

	return speed * speed / (2.0 * mu * gravity)
