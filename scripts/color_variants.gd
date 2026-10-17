class_name ColorVariants
extends RefCounted
## Leichte Farbvarianten für Zellen derselben Art (Farbton und Helligkeit).

const HUE_SPREAD := 0.03
const VALUE_SPREAD := 0.08


## Variante von c; t von -1 bis 1 (wird begrenzt), 0 = unverändert.
static func vary(c: Color, t: float) -> Color:
	var k := clampf(t, -1.0, 1.0)
	var h := wrapf(c.h + HUE_SPREAD * k, 0.0, 1.0)
	var v := clampf(c.v + VALUE_SPREAD * k, 0.0, 1.0)
	return Color.from_hsv(h, c.s, v, c.a)


## Reproduzierbarer Wert von -1 bis 1 aus einer Lage; (0, 0) ergibt 0.
static func seed_for(pos: Vector2) -> float:
	return sin(pos.x * 0.013 + pos.y * 0.007)
