class_name BubbleView
extends Node2D
## Zeichnet die Bläschen einer BubbleTrail als helle Ringe.

var trail: BubbleTrail


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if trail == null:
		return
	for b: Dictionary in trail.bubbles:
		var c := Color(0.8, 0.95, 1.0, BubbleTrail.alpha(b["age"]))
		draw_arc(b["pos"], b["size"], 0.0, TAU, 12, c, 1.0)
