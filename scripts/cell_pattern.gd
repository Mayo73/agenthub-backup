class_name CellPattern
extends RefCounted
## Musterelemente des Zellkörpers. Lagen und Größen in Zellradien, (0, 0) = Zellmitte, Blickrichtung +x.

const STRIPE_XS := [-0.6, -0.3, 0.0, 0.3, 0.6]
const STRIPE_REACH := 0.8


## Elemente eines Musters: Dictionaries mit "pos" (Vector2), "size" (float) und "stripe" (bool).
## Gleiches Muster und gleicher seed_value ergeben immer dieselben Elemente.
static func marks(pattern: String, seed_value: int = 7) -> Array:
	var out := []
	if pattern == "streifen":
		for x: float in STRIPE_XS:
			out.append({"pos": Vector2(x, 0.0), "size": 0.06, "stripe": true})
		return out
	var count := 0
	var size := 0.0
	var max_r := 0.0
	if pattern == "punkte":
		count = 12
		size = 0.07
		max_r = 0.7
	elif pattern == "flecken":
		count = 5
		size = 0.17
		max_r = 0.5
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in count:
		var pos := Vector2.from_angle(rng.randf() * TAU) * sqrt(rng.randf()) * max_r
		out.append({"pos": pos, "size": size, "stripe": false})
	return out


## Halbe Länge eines Streifens an der Stelle x (in Zellradien), damit er im Körper bleibt.
static func stripe_half(x: float) -> float:
	return sqrt(maxf(0.0, STRIPE_REACH * STRIPE_REACH - x * x))


## Lage eines Elements in Pixeln, mit der Streckung des Aussehens (wie CellLook.outline).
static func to_local(pos: Vector2, radius: float, look: CellLook) -> Vector2:
	return Vector2(pos.x * radius * look.stretch, pos.y * radius / look.stretch)
