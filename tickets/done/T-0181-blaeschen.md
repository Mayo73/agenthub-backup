---
id: T-0181
title: Bläschen hinter schwimmenden Zellen (BubbleTrail, BubbleView)
project: zellenphase
priority: 3
---
## Ziel
Mehr Wasserwirkung (Lastenheft „Wasserpartikel“): Hinter einer schnell schwimmenden Zelle steigen kleine Bläschen auf und verblassen. Hier entstehen die Logik und ein Node zum Zeichnen; der Einbau ins Spiel folgt später.

## Dateien
- `scripts/bubble_trail.gd`: neu
- `scripts/bubble_view.gd`: neu
- `tests/test_bubble_trail.gd`: neu

## Akzeptanzkriterien
`scripts/bubble_trail.gd` genau so:
```gdscript
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
```
`scripts/bubble_view.gd` genau so:
```gdscript
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
```

## Tests
`tests/test_bubble_trail.gd` mit `extends "res://tests/base_test.gd"`, `var t: BubbleTrail`; `setup()`: `t = BubbleTrail.new()`.
- `test_ausstossen`: `t.emit(Vector2(5, 5), 2.0)` → `t.bubbles.size()` ist 1; `t.bubbles[0]["size"]` ist 2.0
- `test_aufsteigen`: `t.emit(Vector2(0, 100), 2.0)`, `t.tick(0.5)` → `(t.bubbles[0]["pos"] as Vector2).is_equal_approx(Vector2(0, 91))` wahr; `t.bubbles[0]["age"]` ist 0.5
- `test_verschwinden`: `t.emit(Vector2.ZERO, 2.0)`, `t.tick(1.3)` → `t.bubbles.size()` ist 0
- `test_hoechstzahl`: 45-mal `t.emit(Vector2.ZERO, 1.0)` → `t.bubbles.size()` ist 40
- `test_deckkraft`: `BubbleTrail.alpha(0.0)` ist 0.5; `BubbleTrail.alpha(0.6)` ist 0.25; `BubbleTrail.alpha(5.0)` ist 0.0
- `test_view`: `var v := BubbleView.new()`, `v.trail = t` → `v.trail == t` wahr; danach `v.free()`

Review (17.10.2026): gemergt.
