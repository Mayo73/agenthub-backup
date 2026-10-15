class_name CarCollision
extends RefCounted
## Konstante für die Rückstoßkraft bei Kollisionen (0 = gar nicht, 1 = vollständig elastisch).
const RESTITUTION := 0.3

## Behandelt zwei Autos als Kreise mit Radius `radius`. Gibt true zurück, wenn sie sich berührt haben.
static func resolve(a: CarPhysics, b: CarPhysics, radius: float) -> bool:
	var delta := b.position - a.position
	var dist := delta.length()
	var min_dist := radius * 2.0
	if dist >= min_dist:
		return false
	var normal := Vector2.RIGHT if dist < 0.001 else delta / dist
	var push := (min_dist - dist) * 0.5
	a.position -= normal * push
	b.position += normal * push
	var closing := (b.velocity - a.velocity).dot(normal)
	if closing < 0.0:
		var impulse := -(1.0 + RESTITUTION) * closing * 0.5
		a.velocity -= normal * impulse
		b.velocity += normal * impulse
	return true
