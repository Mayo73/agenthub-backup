class_name ComboCounter
extends RefCounted
## Zählt schnelle Münz-Sammlungen und gibt einen Multiplikator zurück.

const COMBO_WINDOW := 1.5  # Sekunden: maximale Lücke zwischen Münzen für Kombo
const MAX_MULTIPLIER := 5  # Höchster möglicher Multiplikator

var last_coin_time := -1.0
var current_multiplier := 0


## Gibt den Multiplikator für diese Münze zurück.
func register_coin(time_sec: float) -> int:
	if last_coin_time < 0.0 or time_sec - last_coin_time > COMBO_WINDOW:
		current_multiplier = 1
	else:
		current_multiplier = min(current_multiplier + 1, MAX_MULTIPLIER)

	last_coin_time = time_sec
	return current_multiplier


## Die nächste Münze zählt wieder als erste.
func reset() -> void:
	last_coin_time = -1.0
	current_multiplier = 0
