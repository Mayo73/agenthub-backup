class_name EditorPlacement
extends RefCounted
## Umrechnung und Auswahl im Zelleditor. Lagen in Zellradien (wie CellBuild), Blick nach +x.

## Teile dürfen höchstens so weit von der Mitte weg sitzen (1 = Zellrand).
const MAX_DIST := 1.0
## So nah (in Zellradien) muss ein Klick an einem Teil liegen, um es auszuwählen.
const PICK_TOLERANCE := 0.2
const ANGLE_STEP := PI / 8


static func screen_to_local(screen: Vector2, center: Vector2, scale: float) -> Vector2:
	return (screen - center) / scale


static func local_to_screen(local: Vector2, center: Vector2, scale: float) -> Vector2:
	return center + local * scale


static func clamp_to_body(pos: Vector2) -> Vector2:
	if pos.length() > MAX_DIST:
		return pos.normalized() * MAX_DIST
	return pos


## Index des Teils, das local am nächsten liegt (höchstens PICK_TOLERANCE entfernt), sonst -1.
static func part_at(build: CellBuild, local: Vector2) -> int:
	var best := -1
	var best_dist := PICK_TOLERANCE
	for i in build.parts.size():
		var pos: Vector2 = build.parts[i]["pos"]
		var d := local.distance_to(pos)
		if d <= best_dist:
			best = i
			best_dist = d
	return best


## Rastet einen Winkel auf Vielfache von ANGLE_STEP ein.
static func snap_angle(angle: float) -> float:
	return roundf(angle / ANGLE_STEP) * ANGLE_STEP
