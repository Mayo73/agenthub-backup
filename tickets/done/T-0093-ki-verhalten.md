---
id: T-0093
title: Verhalten der KI-Zellen (AiBrain)
project: zellenphase
priority: 4
after: T-0084
---
## Ziel
Andere Zellen entscheiden jede Runde: vor größeren Fleisch- oder Allesfressern fliehen, kleinere Zellen jagen (nur wer Fleisch frisst), sonst passende Nahrung suchen oder treiben.

## Dateien
- `scripts/ai_brain.gd`: neu
- `tests/test_ai_brain.gd`: neu

## Akzeptanzkriterien
`scripts/ai_brain.gd` genau so:
```gdscript
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
```

## Tests
`tests/test_ai_brain.gd` mit `extends "res://tests/base_test.gd"`, `var brain: AiBrain`, `setup()`: `brain = AiBrain.new()`.
- `test_fliehen`: `brain.decide(Vector2.ZERO, 12.0, Diet.PFLANZENFRESSER, [{"position": Vector2(100, 0), "radius": 27.0, "diet": Diet.FLEISCHFRESSER}], null)` ist (-1, 0); `brain.state` ist `AiBrain.FLIEHEN`
- `test_grosser_pflanzenfresser_harmlos`: wie oben, aber der andere ist `Diet.PFLANZENFRESSER`, `food_pos` ist `Vector2(0, 50)` → Ergebnis (0, 1), `brain.state` ist `AiBrain.SUCHEN`
- `test_jagen`: eigene Zelle `Diet.FLEISCHFRESSER` mit Radius 27, anderer Radius 12 bei (0, -100) → (0, -1), `AiBrain.JAGEN`
- `test_ausser_sicht`: anderer Fleischfresser Radius 60 bei (500, 0), kein Futter → `Vector2.ZERO`, `AiBrain.TREIBEN`
- `test_flucht_vor_jagd`: eigene `Diet.FLEISCHFRESSER` Radius 18; Gefahr Radius 40 `Diet.FLEISCHFRESSER` bei (100, 0); Beute Radius 10 bei (-50, 0) → (-1, 0), `AiBrain.FLIEHEN`
- `test_sich_selbst_ignorieren`: Eintrag an der eigenen Position (0, 0) mit Radius 60 `Diet.FLEISCHFRESSER` → `AiBrain.TREIBEN`
- `test_regeln`: `AiBrain.is_threat(12.0, 18.0, Diet.FLEISCHFRESSER)` wahr; `is_threat(27.0, 18.0, Diet.FLEISCHFRESSER)` falsch; `is_prey(27.0, Diet.FLEISCHFRESSER, 18.0)` wahr; `is_prey(27.0, Diet.PFLANZENFRESSER, 18.0)` falsch

Review (16.10.2026): gemergt.
