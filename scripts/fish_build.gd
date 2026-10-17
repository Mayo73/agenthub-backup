class_name FishBuild
extends RefCounted
## Ausbau des Spielerfischs: je Bauteil eine Stufe von 0 bis MAX_LEVEL, dazu Farbe und Ernährung.

const SLOTS := ["schwanz", "flossen", "kiefer", "stacheln", "augen"]
const NAMES := {"schwanz": "Schwanzflosse", "flossen": "Brustflossen", "kiefer": "Kiefer", "stacheln": "Stacheln", "augen": "Augen"}
const MAX_LEVEL := 3

var levels := {"schwanz": 0, "flossen": 0, "kiefer": 0, "stacheln": 0, "augen": 0}
var color := Color(0.5, 0.88, 0.82)
var diet := Diet.PFLANZENFRESSER


## Stufe eines Bauteils; 0 bei unbekanntem Bauteil.
func level(slot: String) -> int:
	return int(levels.get(slot, 0))


## Erhöht ein Bauteil um eine Stufe. false bei unbekanntem Bauteil oder schon höchster Stufe.
func upgrade(slot: String) -> bool:
	if not levels.has(slot) or level(slot) >= MAX_LEVEL:
		return false
	levels[slot] = level(slot) + 1
	return true


## Summe aller Stufen.
func total_levels() -> int:
	var n := 0
	for slot: String in SLOTS:
		n += level(slot)
	return n


func copy() -> FishBuild:
	var b := FishBuild.new()
	b.levels = levels.duplicate()
	b.color = color
	b.diet = diet
	return b


func to_dict() -> Dictionary:
	return {"levels": levels.duplicate(), "color": color.to_html(), "diet": diet}


static func from_dict(d: Dictionary) -> FishBuild:
	var b := FishBuild.new()
	var stored: Dictionary = d.get("levels", {})
	for slot: String in SLOTS:
		b.levels[slot] = clampi(int(stored.get(slot, 0)), 0, MAX_LEVEL)
	b.color = Color.from_string(str(d.get("color", "")), b.color)
	b.diet = str(d.get("diet", Diet.PFLANZENFRESSER))
	return b
