class_name PlaceSketch
extends RefCounted
## Logik zur Erkennung der Ortsart aus Text und Bereitstellung schematischer Formen.
## Reine Logik, keine externen Dienste oder Karten.

const KINDS: Array[String] = ["Park", "Wiese", "Strand", "Sportplatz", "Wald", "Draußen"]

const RULES: Array = [
	["sportplatz", "Sportplatz"],
	["park", "Park"],
	["wiese", "Wiese"],
	["rasen", "Wiese"],
	["strand", "Strand"],
	["ufer", "Strand"],
	["see", "Strand"],
	["wald", "Wald"],
	["platz", "Sportplatz"]
]


## Erkennt die Ortsart aus einem Ortstext.
## Klein geschrieben wird die erste Regel genutzt, deren Stichwort im Text vorkommt.
## Sonst (auch bei leerem Text) → "Draußen".
static func kind_for(place: String) -> String:
	var text := place.to_lower()
	for rule in RULES:
		if text.contains(rule[0] as String):
			return rule[1] as String
	return "Draußen"


## Liefert eine Liste einfacher Formen (schematische Darstellung) für eine Ortsart.
## Jede Form ist ein Dictionary mit relativen Koordinaten (0–1, bezogen auf Breite/Höhe).
static func shapes(kind: String) -> Array[Dictionary]:
	match kind:
		"Park":
			return [
				{"type": "rect", "pos": Vector2(0.0, 0.0), "size": Vector2(1.0, 1.0), "color": Color(0.25, 0.55, 0.30)},
				{"type": "rect", "pos": Vector2(0.0, 0.45), "size": Vector2(1.0, 0.1), "color": Color(0.80, 0.72, 0.55)},
				{"type": "circle", "pos": Vector2(0.2, 0.25), "radius": 0.08, "color": Color(0.15, 0.40, 0.20)},
				{"type": "circle", "pos": Vector2(0.75, 0.2), "radius": 0.08, "color": Color(0.15, 0.40, 0.20)},
				{"type": "circle", "pos": Vector2(0.6, 0.75), "radius": 0.08, "color": Color(0.15, 0.40, 0.20)}
			]
		"Wiese":
			return [
				{"type": "rect", "pos": Vector2(0.0, 0.0), "size": Vector2(1.0, 1.0), "color": Color(0.40, 0.70, 0.35)},
				{"type": "circle", "pos": Vector2(0.3, 0.3), "radius": 0.03, "color": Color(0.95, 0.85, 0.30)},
				{"type": "circle", "pos": Vector2(0.7, 0.6), "radius": 0.03, "color": Color(0.95, 0.85, 0.30)}
			]
		"Strand":
			return [
				{"type": "rect", "pos": Vector2(0.0, 0.0), "size": Vector2(1.0, 1.0), "color": Color(0.90, 0.82, 0.60)},
				{"type": "rect", "pos": Vector2(0.0, 0.0), "size": Vector2(1.0, 0.4), "color": Color(0.25, 0.50, 0.80)}
			]
		"Sportplatz":
			return [
				{"type": "rect", "pos": Vector2(0.0, 0.0), "size": Vector2(1.0, 1.0), "color": Color(0.30, 0.60, 0.30)},
				{"type": "rect", "pos": Vector2(0.1, 0.1), "size": Vector2(0.8, 0.8), "color": Color(0.35, 0.68, 0.35)},
				{"type": "circle", "pos": Vector2(0.5, 0.5), "radius": 0.1, "color": Color(0.95, 0.95, 0.95)}
			]
		"Wald":
			return [
				{"type": "rect", "pos": Vector2(0.0, 0.0), "size": Vector2(1.0, 1.0), "color": Color(0.18, 0.40, 0.22)},
				{"type": "circle", "pos": Vector2(0.2, 0.2), "radius": 0.1, "color": Color(0.10, 0.30, 0.15)},
				{"type": "circle", "pos": Vector2(0.5, 0.3), "radius": 0.1, "color": Color(0.10, 0.30, 0.15)},
				{"type": "circle", "pos": Vector2(0.8, 0.2), "radius": 0.1, "color": Color(0.10, 0.30, 0.15)},
				{"type": "circle", "pos": Vector2(0.3, 0.7), "radius": 0.1, "color": Color(0.10, 0.30, 0.15)},
				{"type": "circle", "pos": Vector2(0.7, 0.75), "radius": 0.1, "color": Color(0.10, 0.30, 0.15)}
			]
		"Draußen":
			return [
				{"type": "rect", "pos": Vector2(0.0, 0.0), "size": Vector2(1.0, 1.0), "color": Color(0.40, 0.55, 0.70)},
				{"type": "rect", "pos": Vector2(0.0, 0.6), "size": Vector2(1.0, 0.4), "color": Color(0.35, 0.60, 0.35)}
			]
		_:
			return [
				{"type": "rect", "pos": Vector2(0.0, 0.0), "size": Vector2(1.0, 1.0), "color": Color(0.40, 0.55, 0.70)},
				{"type": "rect", "pos": Vector2(0.0, 0.6), "size": Vector2(1.0, 0.4), "color": Color(0.35, 0.60, 0.35)}
			]


## Liefert eine Beschriftung für die Skizze einer Ortsart.
static func caption(kind: String) -> String:
	if kind == "Draußen":
		return "Skizze: draußen (schematisch, keine Karte)"
	else:
		return "Skizze: %s (schematisch, keine Karte)" % kind
