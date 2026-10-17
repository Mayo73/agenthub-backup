class_name ChaseCamera
extends RefCounted
## Verfolgerkamera der Fischphase: hinter und etwas über dem Fisch, folgt weich und bleibt unter Wasser.

const DISTANCE := 6.0
const HEIGHT := 1.5
## Je größer, desto schneller holt die Kamera auf.
const FOLLOW := 4.0


## Wunschlage: DISTANCE * size hinter dem Fisch (waagrecht entgegen der Blickrichtung) und HEIGHT * size darüber.
static func target_position(fish_pos: Vector3, yaw: float, size: float = 1.0) -> Vector3:
	var back := -FishMotion.forward_of(yaw, 0.0)
	var p := fish_pos + back * DISTANCE * size + Vector3.UP * HEIGHT * size
	return FishWorld.clamp_to_water(p, 0.3)


## Weiches Folgen: nähert current an target an, unabhängig von der Bildrate.
static func follow(current: Vector3, target: Vector3, delta: float) -> Vector3:
	return current.lerp(target, 1.0 - exp(-FOLLOW * delta))
