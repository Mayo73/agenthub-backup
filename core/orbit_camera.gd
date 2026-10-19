class_name OrbitCamera
extends RefCounted

## OrbitCamera – Kameraposition um ein Ziel aus Gieren, Neigen und Abstand.
## Winkel in Grad. Gieren (yaw) 0 heißt: Kamera auf der +z-Seite des Ziels.
## Positives Gieren dreht gegen den Uhrzeigersinn von oben gesehen (Richtung +x).
## Neigen (pitch) positiv heißt: Kamera über dem Ziel.

var target: Vector3 = Vector3.ZERO
var yaw: float = 0.0
var pitch: float = 20.0
var distance: float = 6.0

const MIN_PITCH := -89.0
const MAX_PITCH := 89.0
const MIN_DISTANCE := 0.5
const MAX_DISTANCE := 500.0

## Berechnet die Kameraposition basierend auf Ziel, Gieren, Neigen und Abstand.
func position() -> Vector3:
	var y: float = deg_to_rad(yaw)
	var p: float = deg_to_rad(pitch)
	return target + Vector3(sin(y) * cos(p), sin(p), cos(y) * cos(p)) * distance

## Ändert Gieren und Neigen. Gieren wird auf 0-360 begrenzt, Neigen auf MIN_PITCH/MAX_PITCH.
func orbit(d_yaw: float, d_pitch: float) -> void:
	yaw = fposmod(yaw + d_yaw, 360.0)
	pitch = clampf(pitch + d_pitch, MIN_PITCH, MAX_PITCH)

## Zoomt mit einem Faktor. factors <= 0 werden ignoriert, distance wird geklammert.
func zoom(factor: float) -> void:
	if factor <= 0.0:
		return
	distance = clampf(distance * factor, MIN_DISTANCE, MAX_DISTANCE)

## Verschiebt das Ziel.
func pan(offset: Vector3) -> void:
	target += offset

## Wandelt den Zustand in ein Dictionary um (target als [x, y, z]).
func to_dict() -> Dictionary:
	return {
		"target": [target.x, target.y, target.z],
		"yaw": yaw,
		"pitch": pitch,
		"distance": distance
	}

## Erstellt einen OrbitCamera aus einem Dictionary. Fehlende Werte behalten den Standard.
static func from_dict(d: Dictionary) -> OrbitCamera:
	var cam: OrbitCamera = OrbitCamera.new()
	if d.has("target"):
		var t: Array = d["target"]
		cam.target = Vector3(t[0], t[1], t[2])
	if d.has("yaw"):
		cam.yaw = d["yaw"]
	if d.has("pitch"):
		cam.pitch = d["pitch"]
	if d.has("distance"):
		cam.distance = d["distance"]
	return cam
