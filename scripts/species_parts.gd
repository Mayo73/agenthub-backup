class_name SpeciesParts
extends RefCounted
## Sichtbare Teile der KI-Arten (nur Darstellung; Werte und Verhalten stehen im SpeciesCatalog).
## Lage in Zellradien wie in CellBuild, (0, 0) = Zellmitte, Blickrichtung +x.

const PARTS := {
	"blasenling": [{"id": "filtermaul", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "wimpern", "pos": Vector2(-1, 0), "angle": 0.0}],
	"schnapper": [{"id": "kiefer", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "geissel", "pos": Vector2(-1, 0), "angle": 0.0}],
	"stachelkugel": [{"id": "filtermaul", "pos": Vector2(1, 0), "angle": 0.0}],
	"giftling": [{"id": "ruessel", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "gift", "pos": Vector2(-0.5, 0.45), "angle": 0.0}, {"id": "gift", "pos": Vector2(-0.5, -0.45), "angle": 0.0}],
	"zitterzelle": [{"id": "kiefer", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "elektro", "pos": Vector2(-0.4, 0), "angle": 0.0}, {"id": "geissel", "pos": Vector2(-1, 0), "angle": 0.0}],
	"weidezelle": [{"id": "filtermaul", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "wimpern", "pos": Vector2(0, 1), "angle": 0.0}, {"id": "wimpern", "pos": Vector2(0, -1), "angle": 0.0}],
	"hornjaeger": [{"id": "kiefer", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "stachel", "pos": Vector2(0.7, 0.7), "angle": 0.0}, {"id": "stachel", "pos": Vector2(0.7, -0.7), "angle": 0.0}, {"id": "duese", "pos": Vector2(-1, 0), "angle": 0.0}],
	"riesenschlund": [{"id": "kiefer", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "geissel", "pos": Vector2(-0.7, 0.7), "angle": 0.0}, {"id": "geissel", "pos": Vector2(-0.7, -0.7), "angle": 0.0}],
	"flimmerling": [{"id": "filtermaul", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "geissel", "pos": Vector2(-1, 0), "angle": 0.0}],
	"panzerling": [{"id": "filtermaul", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "stachel", "pos": Vector2(-0.7, 0.7), "angle": 0.0}, {"id": "stachel", "pos": Vector2(-0.7, -0.7), "angle": 0.0}],
	"schwebqualle": [{"id": "filtermaul", "pos": Vector2(1, 0), "angle": 0.0}, {"id": "wimpern", "pos": Vector2(-1, 0), "angle": 0.0}, {"id": "wimpern", "pos": Vector2(0, 1), "angle": 0.0}, {"id": "wimpern", "pos": Vector2(0, -1), "angle": 0.0}],
}


## Teile einer Art; leer bei unbekannter ID.
static func parts_of(id: String) -> Array:
	return PARTS.get(id, [])


## Kopien der Teile, deren Lage mit der Streckung des Körpers mitgeht (wie CellLook.outline).
static func placed_parts(id: String, stretch: float) -> Array:
	var out := []
	for part: Dictionary in parts_of(id):
		var copy := part.duplicate()
		var pos: Vector2 = part["pos"]
		copy["pos"] = Vector2(pos.x * stretch, pos.y / stretch)
		out.append(copy)
	return out
