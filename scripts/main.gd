extends Node2D
## Hauptszene: verbindet Münzen mit dem Spielstand und aktualisiert das HUD.

var state := GameState.new()

@onready var _score_label: Label = $HUD/ScoreLabel


func _ready() -> void:
	state.score_changed.connect(_on_score_changed)
	for coin in $Coins.get_children():
		coin.collected.connect(state.add_coin)
	_on_score_changed(state.score)


func _on_score_changed(new_score: int) -> void:
	_score_label.text = "Münzen: %d" % new_score
