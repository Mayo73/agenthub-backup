class_name FollowCamera3D
extends RefCounted

## FollowCamera3D – Verfolgerkamera, die von hinten oben folgt.
## Reine Rechnung ohne Nodes oder Szenenbaum.

var distance: float = 6.0
var height: float = 2.5
var smoothing: float = 5.0
var position: Vector3 = Vector3.ZERO

## Berechnet die gewünschte Kameraposition: distance hinter dem Ziel
## und height darüber. „Vorne" bei yaw ist Vector3(sin(yaw), 0, -cos(yaw))
## (bei yaw 0 also -z).
func desired(target: Vector3, yaw: float) -> Vector3:
	var vorne: Vector3 = Vector3(sin(yaw), 0.0, -cos(yaw))
	return target - vorne * distance + Vector3(0.0, height, 0.0)

## Setzt die Kamera sofort auf die gewünschte Position.
func snap(target: Vector3, yaw: float) -> void:
	position = desired(target, yaw)

## Führt eine weiche Interpolation zur gewünschten Position aus und gibt
## die neue Kameraposition zurück. Bei smoothing <= 0 wie snap.
func update(target: Vector3, yaw: float, dt: float) -> Vector3:
	var d: Vector3 = desired(target, yaw)
	if smoothing <= 0.0:
		position = d
	else:
		var t: float = clampf(smoothing * dt, 0.0, 1.0)
		position = position.lerp(d, t)
	return position

## Gibt den Blickpunkt zurück (Ziel + y-Richtung).
func look_target(target: Vector3) -> Vector3:
	return target + Vector3(0.0, 1.0, 0.0)
