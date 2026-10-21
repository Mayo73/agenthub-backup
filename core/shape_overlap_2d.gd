extends RefCounted
class_name ShapeOverlap2D

## Statische Methoden für 2D-Kollisionsprüfungen mit Eindringtiefe.


## Kreiskreis-Überlappung: Abstand der Radien minus tatsächlicher Abstand, >0 wenn Überlappung.
static func circles(c1: Vector2, r1: float, c2: Vector2, r2: float) -> float:
	var dist: float = c1.distance_to(c2)
	var overlap: float = r1 + r2 - dist
	return maxf(overlap, 0.0)


## Rechteck-Rechteck-Überlappung: kleinste Verschiebung, die a aus b herausschiebt.
static func rects(a: Rect2, b: Rect2) -> Vector2:
	var ox: float = minf(a.end.x, b.end.x) - maxf(a.position.x, b.position.x)
	var oy: float = minf(a.end.y, b.end.y) - maxf(a.position.y, b.position.y)
	if ox <= 0.0 or oy <= 0.0:
		return Vector2.ZERO
	var center_a: Vector2 = a.get_center()
	var center_b: Vector2 = b.get_center()
	if ox <= oy:
		if center_a.x < center_b.x:
			return Vector2(-ox, 0.0)
		else:
			return Vector2(ox, 0.0)
	else:
		if center_a.y < center_b.y:
			return Vector2(0.0, -oy)
		else:
			return Vector2(0.0, oy)


## Kreis-Rechteck-Überlappung: Eindringtiefe des Kreises in das Rechteck.
static func circle_rect(c: Vector2, r: float, rect: Rect2) -> float:
	var nearest: Vector2 = c.clamp(rect.position, rect.end)
	var dist: float = c.distance_to(nearest)
	var overlap: float = r - dist
	return maxf(overlap, 0.0)


## Punkt in Kreis-Test: Abstand <= Radius.
static func point_in_circle(p: Vector2, c: Vector2, r: float) -> bool:
	return p.distance_to(c) <= r
