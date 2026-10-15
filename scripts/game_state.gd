class_name GameState
extends RefCounted
## Reiner Spielstand ohne Szenenabhängigkeit, damit er sich gut testen lässt.

signal score_changed(new_score: int)

var score := 0
var coins_collected := 0


func add_coin(value: int = 1) -> void:
	coins_collected += 1
	score += value
	score_changed.emit(score)


func reset() -> void:
	score = 0
	coins_collected = 0
	score_changed.emit(score)
