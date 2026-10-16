class_name CellBody
extends RefCounted
## Lebendig wirkender Zellkörper: Umriss mit sanft wogender Membran und Texturkoordinaten.

const WAVE_AMOUNT := 0.04
const WAVE_COUNT := 5
const WAVE_SPEED := 2.0


## Umriss aus look.outline(), jeder Punkt um bis zu WAVE_AMOUNT nach außen oder innen verschoben.
static func wobble(look: CellLook, radius: float, time: float, points: int = 32) -> PackedVector2Array:
	var base := look.outline(radius, points)
	var out := PackedVector2Array()
	for i in base.size():
		var a := TAU * i / points
		out.append(base[i] * (1.0 + WAVE_AMOUNT * sin(a * WAVE_COUNT + time * WAVE_SPEED)))
	return out


## Halbe Breite und Höhe des größtmöglichen Umrisses (mit Streckung und Wogen).
static func half_size(look: CellLook, radius: float) -> Vector2:
	var f := 1.0 + WAVE_AMOUNT
	return Vector2(radius * look.stretch * f, radius / look.stretch * f)


## Texturkoordinaten (0 bis 1) zu den Punkten eines Umrisses; die Textur wird mit dem Körper gestreckt.
static func uvs(outline: PackedVector2Array, half: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in outline:
		out.append(Vector2(p.x / (2.0 * half.x), p.y / (2.0 * half.y)) + Vector2(0.5, 0.5))
	return out
