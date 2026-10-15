class_name GameState
extends RefCounted
## Reiner Spielstand ohne Szenenabhängigkeit, damit er sich gut testen lässt.

signal score_changed(new_score: int)
signal high_score_changed(new_high_score: int)

var score := 0
var coins_collected := 0
var high_score := 0


func add_coin(value: int = 1) -> void:
	coins_collected += 1
	score += value
	score_changed.emit(score)
	if score > high_score:
		high_score = score
		high_score_changed.emit(high_score)


func reset() -> void:
	score = 0
	coins_collected = 0
	score_changed.emit(score)


func average_coin_value() -> float:
	if coins_collected == 0:
		return 0.0
	return float(score) / coins_collected
