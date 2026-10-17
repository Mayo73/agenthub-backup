class_name PlayerMarker
extends Node2D
## Heller Ring auf dem Boden unter dem Spielerauto, damit man es von gleichfarbigen Gegnern unterscheidet.
## Liegt unter "World" (Weltkoordinaten) und folgt dem Auto in target.

const RADIUS := 34.0
const WIDTH := 5.0
const COLOR := Color(1.0, 0.92, 0.3, 0.9)
const FILL := Color(1.0, 0.92, 0.3, 0.18)

var target: Node2D


## Übernimmt die Lage des Autos (ohne Drehung, der Ring ist rund).
func follow() -> void:
	if target:
		position = target.position


func _process(_delta: float) -> void:
	follow()


func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, FILL)
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 48, COLOR, WIDTH, true)
