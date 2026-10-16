class_name CellShading
extends RefCounted
## Räumliche Wirkung der Zellen: Schatten nach unten rechts, Glanzlicht oben links.
## Das Licht kommt immer von oben links auf dem Bildschirm, auch wenn die Zelle gedreht ist.

const SHADOW_OFFSET := Vector2(0.12, 0.16)
const SHADOW_COLOR := Color(0.0, 0.05, 0.1, 0.35)
const HIGHLIGHT_POS := Vector2(-0.35, -0.4)
const HIGHLIGHT_SIZE := 0.28


## Versatz des Schattens in Pixeln, im Koordinatensystem der um rotation gedrehten Zelle.
static func shadow_offset(radius: float, rotation: float) -> Vector2:
	return (SHADOW_OFFSET * radius).rotated(-rotation)


## Mitte des Glanzlichts in Pixeln, im Koordinatensystem der um rotation gedrohten Zelle.
static func highlight_center(radius: float, rotation: float) -> Vector2:
	return (HIGHLIGHT_POS * radius).rotated(-rotation)


static func highlight_radius(radius: float) -> float:
	return radius * HIGHLIGHT_SIZE


static func highlight_color(look: CellLook) -> Color:
	var c := look.color.lightened(0.6)
	c.a = 0.35
	return c
