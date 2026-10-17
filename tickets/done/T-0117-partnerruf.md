---
id: T-0117
title: Partnerruf (MateCall)
project: zellenphase
priority: 5
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Wie bei Spore bringt jeder neue Größenabschnitt einen Ruf. Der Ruf lässt einen Partner vor der Zelle erscheinen; wer ihn erreicht, kommt in den Zelleditor. Diese Klasse enthält nur die Logik.

## Dateien
- `scripts/mate_call.gd`: neu
- `tests/test_mate_call.gd`: neu

## Akzeptanzkriterien
`scripts/mate_call.gd` genau so:
```gdscript
class_name MateCall
extends RefCounted
## Partnersuche wie bei Spore: Jeder neue Größenabschnitt bringt einen Ruf.
## Der Ruf lässt einen Partner vor der Zelle erscheinen; wer ihn erreicht, kommt in den Zelleditor.

const PARTNER_DIST := 250.0
const PARTNER_RADIUS := 12.0

var charges := 0
## Lage des Partners oder null, solange keiner gerufen wurde.
var partner_pos: Variant = null


func add_charge() -> void:
	charges += 1


func can_call() -> bool:
	return charges > 0 and partner_pos == null


## Ruft einen Partner in Blickrichtung vor die Zelle. false, wenn kein Ruf bereitsteht.
func call_partner(player_pos: Vector2, heading: float) -> bool:
	if not can_call():
		return false
	charges -= 1
	partner_pos = player_pos + Vector2.from_angle(heading) * PARTNER_DIST
	return true


func reached(player_pos: Vector2, player_radius: float) -> bool:
	if partner_pos == null:
		return false
	return player_pos.distance_to(partner_pos as Vector2) <= player_radius + PARTNER_RADIUS


## Nach dem Editorbesuch verschwindet der Partner.
func finish() -> void:
	partner_pos = null
```

## Tests
`tests/test_mate_call.gd` mit `extends "res://tests/base_test.gd"`, `var m: MateCall`, `setup()`: `m = MateCall.new()`.
- `test_ohne_ruf`: `m.can_call()` falsch; `m.call_partner(Vector2.ZERO, 0.0)` falsch; `m.partner_pos == null` wahr
- `test_rufen`: `m.add_charge()`; `m.can_call()` wahr; `m.call_partner(Vector2(10, 0), 0.0)` wahr; `m.partner_pos` ist (260, 0); `m.charges` ist 0
- `test_nur_ein_partner`: `m.add_charge()`, `m.add_charge()`, `m.call_partner(Vector2.ZERO, 0.0)` → `m.can_call()` falsch, `m.call_partner(Vector2.ZERO, 0.0)` falsch, `m.charges` ist 1; nach `m.finish()` ist `m.can_call()` wahr
- `test_erreichen`: `m.add_charge()`, `m.call_partner(Vector2(10, 0), 0.0)` → `m.reached(Vector2(240, 0), 12.0)` wahr; `m.reached(Vector2(200, 0), 12.0)` falsch; nach `m.finish()` ist `m.reached(Vector2(260, 0), 12.0)` falsch

Review (16.10.2026): gemergt.
