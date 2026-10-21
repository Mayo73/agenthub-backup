extends RefCounted
class_name TargetScore

## Zielscheibe mit Ringen und Wertung
var radius: float = 1.0
var rings: int = 10
var hits: Array[int] = []

func _init(radius_value: float = 1.0, ring_count: int = 10) -> void:
	radius = radius_value
	rings = ring_count


func set_radius(v: float) -> void:
	radius = max(0.0, v)


func set_rings(v: int) -> void:
	rings = max(1, v)


## Bestimmt den Ring basierend auf Abstand zur Mitte
## distance < 0 wie 0 behandeln; distance > radius → 0 (daneben); sonst rings - floori(distance / radius * rings), mindestens 1
func ring_for(distance: float) -> int:
	if distance < 0.0:
		distance = 0.0
	if distance > radius:
		return 0
	var d := distance / radius * rings
	var ring := rings - floori(d)
	return max(1, ring)


## Wertet einen Treffer im 2D-Flachbild aus
func hit_2d(center: Vector2, point: Vector2) -> int:
	var dist: float = (point - center).length()
	var ring: int = ring_for(dist)
	hits.append(ring)
	return ring


## Wertet einen Treffer im 3D-Raum aus
func hit_3d(center: Vector3, point: Vector3) -> int:
	var dist: float = (point - center).length()
	var ring: int = ring_for(dist)
	hits.append(ring)
	return ring


## Summe aller Trefferwerte
func total() -> int:
	var sum: int = 0
	for h in hits:
		sum += h
	return sum


## Durchschnittlicher Trefferwert, ohne Treffer 0.0
func average() -> float:
	if hits.is_empty():
		return 0.0
	var sum: int = 0
	for h in hits:
		sum += h
	return float(sum) / float(hits.size())


## Trefferliste leeren
func reset() -> void:
	hits.clear()
