class_name ElectricArcs
extends RefCounted
## Zickzacklinie eines Blitzes von from nach to.


## segments Teilstücke (mindestens 1), also segments + 1 Punkte. Die inneren Punkte weichen
## höchstens jitter Pixel quer zur Linie ab; gleicher seed_value ergibt dieselbe Linie.
static func arc(from: Vector2, to: Vector2, segments: int, jitter: float, seed_value: int) -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var n := maxi(1, segments)
	var side := (to - from).normalized().orthogonal()
	var points := PackedVector2Array()
	for i in n + 1:
		var p := from.lerp(to, float(i) / n)
		if i > 0 and i < n:
			p += side * rng.randf_range(-jitter, jitter)
		points.append(p)
	return points
