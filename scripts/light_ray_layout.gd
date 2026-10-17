class_name LightRayLayout
extends RefCounted
## Lichtstrahlen der Fischphase: feste Lage um die Kamera, leichtes Schwanken, schwächer in der Tiefe.

## Anzahl der Strahlen.
const COUNT := 14
## Die Strahlen stehen in x und z höchstens so weit (Meter) von der Kamera entfernt.
const SPREAD := 40.0
## Länge eines Strahls von der Oberfläche nach unten (Meter).
const LENGTH := 32.0
## Größte Deckkraft (nahe der Oberfläche).
const MAX_ALPHA := 0.22
## Ab dieser Tiefe (Meter) sind die Strahlen nicht mehr zu sehen.
const FADE_DEPTH := 45.0


## Waagrechte Versätze der Strahlen (y = 0), immer gleich für denselben seed_value.
static func offsets(count: int, seed_value: int) -> Array[Vector3]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var out: Array[Vector3] = []
	for i in count:
		out.append(Vector3(rng.randf_range(-SPREAD, SPREAD), 0.0, rng.randf_range(-SPREAD, SPREAD)))
	return out


## Neigung (Bogenmaß) des Strahls index zur Zeit t: schwankt langsam um 0,25 rad.
static func tilt(t: float, index: int) -> float:
	return 0.25 + sin(t * 0.3 + float(index) * 1.7) * 0.06


## Deckkraft der Strahlen, wenn die Kamera in depth Metern Tiefe ist.
static func alpha_for_depth(depth: float) -> float:
	return clampf(MAX_ALPHA * (1.0 - depth / FADE_DEPTH), 0.0, MAX_ALPHA)
