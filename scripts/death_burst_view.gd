class_name DeathBurstView
extends Node2D
## Zeichnet die Bruchstücke geplatzter Zellen und lässt sie altern.

var bursts := DeathBursts.new()


func _process(delta: float) -> void:
	bursts.tick(delta)
	queue_redraw()


func _draw() -> void:
	for b: Dictionary in bursts.bursts:
		var c: Color = b["color"]
		c.a = 0.8 * (1.0 - DeathBursts.progress(b["age"]))
		for p in DeathBursts.pieces(b["pos"], b["radius"], b["age"]):
			draw_circle(p, DeathBursts.piece_size(b["radius"], b["age"]), c)
