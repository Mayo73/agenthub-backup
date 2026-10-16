class_name CellLook
extends RefCounted
## Aussehen des Zellkörpers: Farbe, Muster und Körperform (Streckung).

const PATTERNS := ["keins", "punkte", "streifen", "flecken"]
const MIN_STRETCH := 0.7
const MAX_STRETCH := 1.5
const DEFAULT_COLOR := Color(0.5, 0.88, 0.82)


var color := DEFAULT_COLOR
var pattern := "keins"
## Streckung in Blickrichtung: 1 = rund, >1 länglich, <1 breit
var stretch := 1.0


func set_pattern(p: String) -> bool:
	if p in PATTERNS:
		pattern = p
		return true
	return false


func set_stretch(s: float) -> void:
	stretch = clampf(s, MIN_STRETCH, MAX_STRETCH)


func copy() -> CellLook:
	var c := CellLook.new()
	c.color = color
	c.pattern = pattern
	c.stretch = stretch
	return c


func outline(radius: float, points: int = 24) -> PackedVector2Array:
	var result: PackedVector2Array
	result.resize(points)
	for i in range(points):
		var a := TAU * i / points
		result[i] = Vector2(cos(a) * radius * stretch, sin(a) * radius / stretch)
	return result


func to_dict() -> Dictionary:
	return {
		"color": color.to_html(),
		"pattern": pattern,
		"stretch": stretch
	}


static func from_dict(d: Dictionary) -> CellLook:
	var c := CellLook.new()
	c.color = Color.from_string(str(d.get("color", "")), DEFAULT_COLOR)
	c.set_pattern(str(d.get("pattern", "keins")))
	c.set_stretch(float(d.get("stretch", 1.0)))
	return c
