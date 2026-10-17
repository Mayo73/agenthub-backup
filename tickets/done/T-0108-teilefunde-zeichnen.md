---
id: T-0108
title: Teilefunde zeichnen (PickupView)
project: zellenphase
priority: 3
after: T-0106
---
## Ziel
Teilefunde sind im Wasser als pulsierende helle Rauten zu sehen (Platzhalter, bis Higgsfield-Grafik kommt).

## Dateien
- `scripts/pickup_view.gd`: neu
- `tests/test_pickup_view.gd`: neu

## Akzeptanzkriterien
`scripts/pickup_view.gd` genau so:
```gdscript
class_name PickupView
extends Node2D
## Zeichnet die Teilefunde (Platzhalter: pulsierende helle Rauten).

const COLOR := Color(1.0, 0.95, 0.6)

var pickups: PartPickups
var time := 0.0


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


## Eckpunkte der Raute um pos. Die Größe pulsiert mit der Zeit t zwischen dem 0,8- und 1,2-fachen von PartPickups.RADIUS.
static func diamond(pos: Vector2, t: float) -> PackedVector2Array:
	var s := PartPickups.RADIUS * (1.0 + 0.2 * sin(t * 4.0))
	return PackedVector2Array([pos + Vector2(s, 0), pos + Vector2(0, s), pos + Vector2(-s, 0), pos + Vector2(0, -s)])


func _draw() -> void:
	if pickups == null:
		return
	for p in pickups.positions:
		draw_colored_polygon(diamond(p, time), COLOR)
```

## Tests
`tests/test_pickup_view.gd` mit `extends "res://tests/base_test.gd"`:
- `test_raute`: `var d := PickupView.diamond(Vector2(10, 0), 0.0)` → `d.size()` ist 4, `d[0]` ist (19, 0), `d[3]` ist (10, -9)
- `test_pulsieren`: `PickupView.diamond(Vector2.ZERO, PI / 8)[0].x` ist 10.8
- `test_zeit`: `var v := PickupView.new()`, `v._process(0.5)` → `v.time` ist 0.5; danach `v.free()`

Review (16.10.2026): gemergt.
