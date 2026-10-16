class_name BubbleTrail
extends RefCounted
## Bläschen hinter schwimmenden Zellen: steigen langsam auf und verblassen.

const LIFETIME := 1.2
const MAX_BUBBLES := 40
const RISE := 18.0

## Je Bläschen ein Dictionary mit "pos" (Vector2), "age" (float) und "size" (float).
var bubbles: Array = []


func emit(pos: Vector2, size: float) -> void:
	bubbles.append({"pos": pos, "age": 0.0, "size": size})
	if bubbles.size() > MAX_BUBBLES:
		bubbles.pop_front()


func tick(delta: float) -> void:
	var kept := []
	for b: Dictionary in bubbles:
		b["age"] = float(b["age"]) + delta
		b["pos"] = (b["pos"] as Vector2) + Vector2(0, -RISE * delta)
		if b["age"] < LIFETIME:
			kept.append(b)
	bubbles = kept


## Deckkraft eines Bläschens nach age Sekunden (0,5 am Anfang, 0 am Ende).
static func alpha(age: float) -> float:
	return clampf(1.0 - age / LIFETIME, 0.0, 1.0) * 0.5
