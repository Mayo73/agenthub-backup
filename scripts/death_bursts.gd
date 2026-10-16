class_name DeathBursts
extends RefCounted
## Geplatzte Zellen: Bruchstücke fliegen auseinander und verblassen.

const DURATION := 0.6
const PIECES := 10
const MAX_BURSTS := 12

## Je Platzen ein Dictionary mit "pos" (Vector2), "radius" (float), "color" (Color) und "age" (float).
var bursts: Array = []


func add(pos: Vector2, radius: float, color: Color) -> void:
	bursts.append({"pos": pos, "radius": radius, "color": color, "age": 0.0})
	if bursts.size() > MAX_BURSTS:
		bursts.pop_front()


func tick(delta: float) -> void:
	var kept := []
	for b: Dictionary in bursts:
		b["age"] = float(b["age"]) + delta
		if b["age"] < DURATION:
			kept.append(b)
	bursts = kept


## Fortschritt von 0 (gerade geplatzt) bis 1 (vorbei).
static func progress(age: float) -> float:
	return clampf(age / DURATION, 0.0, 1.0)


## Lage der Bruchstücke: gleichmäßig rundum, sie fliegen von 0,5 auf 2 Radien hinaus.
static func pieces(center: Vector2, radius: float, age: float) -> PackedVector2Array:
	var dist := radius * (0.5 + 1.5 * progress(age))
	var out := PackedVector2Array()
	for i in PIECES:
		out.append(center + Vector2.from_angle(TAU * i / PIECES) * dist)
	return out


## Größe eines Bruchstücks: schrumpft von 0,3 Radien auf 0.
static func piece_size(radius: float, age: float) -> float:
	return radius * 0.3 * (1.0 - progress(age))
