class_name Damping
extends RefCounted

## Statische Funktionen für lineare und Winkeldämpfung in 2D und 3D.
## Geschwindigkeiten pro Schritt dämpfen, unabhängig von der Schrittweite gleich stark.


## Berechnet den Dämpfungs-Faktor für gegebenen Dämpfungswert und Delta-Zeit.
static func factor(damp: float, dt: float) -> float:
	if damp <= 0.0:
		return 1.0
	return exp(-damp * dt)


## Dämpft einen 2D-Vektor und setzt sehr kleine Geschwindigkeiten auf NULL.
static func apply(v: Vector2, damp: float, dt: float) -> Vector2:
	var f := factor(damp, dt)
	v = v * f
	if abs(v.length()) < 0.001:
		return Vector2.ZERO
	return v


## Dämpft einen 3D-Vektor und setzt sehr kleine Geschwindigkeiten auf NULL.
static func apply_3d(v: Vector3, damp: float, dt: float) -> Vector3:
	var f := factor(damp, dt)
	v = v * f
	if abs(v.length()) < 0.001:
		return Vector3.ZERO
	return v


## Dämpft eine Winkelgeschwindigkeit und setzt sehr kleine Werte auf NULL.
static func apply_angular(w: float, damp: float, dt: float) -> float:
	w *= factor(damp, dt)
	if abs(w) < 0.001:
		return 0.0
	return w


## Berechnet die Halbwertszeit für gegebenen Dämpfungswert (in Sekunden).
static func half_life(damp: float) -> float:
	if damp <= 0.0:
		return INF
	return log(2.0) / damp
