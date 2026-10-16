class_name AiBrain
extends RefCounted
## Entscheidung einer KI-Zelle: fliehen > jagen > Nahrung suchen > treiben.

const SUCHEN := "suchen"
const JAGEN := "jagen"
const FLIEHEN := "fliehen"
const TREIBEN := "treiben"
## Wer um diesen Faktor größer ist und Fleisch frisst, ist eine Gefahr.
const THREAT_FACTOR := 1.2
## Wer um diesen Faktor kleiner ist, ist Beute (nur für Fleisch- und Allesfresser).
const PREY_FACTOR := 0.8

var sight := 350.0
var state := TREIBEN


static func is_threat(own_radius: float, other_radius: float, other_diet: String) -> bool:
	return other_diet != Diet.PFLANZENFRESSER and other_radius > own_radius * THREAT_FACTOR


static func is_prey(own_radius: float, own_diet: String, other_radius: float) -> bool:
	return own_diet != Diet.PFLANZENFRESSER and other_radius < own_radius * PREY_FACTOR


## others: Dictionaries mit "position" (Vector2), "radius" (float), "diet" (String).
## Einträge an der eigenen Position werden übersprungen (die Zelle selbst).
## food_pos: Lage der nächsten passenden Nahrung oder null.
## Gibt die Schwimmrichtung zurück (Länge 1 oder Vector2.ZERO) und setzt state.
func decide(own_pos: Vector2, own_radius: float, own_diet: String, others: Array, food_pos: Variant) -> Vector2:
	var threat_pos := Vector2.ZERO
	var threat_dist := INF
	var prey_pos := Vector2.ZERO
	var prey_dist := INF
	for other in others:
		var pos: Vector2 = other["position"]
		var dist := own_pos.distance_to(pos)
		if dist > sight or dist < 0.001:
			continue
		if is_threat(own_radius, other["radius"], other["diet"]):
			if dist < threat_dist:
				threat_dist = dist
				threat_pos = pos
		elif is_prey(own_radius, own_diet, other["radius"]):
			if dist < prey_dist:
				prey_dist = dist
				prey_pos = pos
	if threat_dist < INF:
		state = FLIEHEN
		return (own_pos - threat_pos).normalized()
	if prey_dist < INF:
		state = JAGEN
		return (prey_pos - own_pos).normalized()
	if food_pos is Vector2:
		state = SUCHEN
		return ((food_pos as Vector2) - own_pos).normalized()
	state = TREIBEN
	return Vector2.ZERO
