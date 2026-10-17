---
id: T-0176
title: Aufblitzen bei Treffern (HitFlash)
project: zellenphase
priority: 2
---
## Ziel
Das Lastenheft verlangt sichtbare Trefferreaktionen. Getroffene Zellen sollen kurz rot aufblitzen. Diese Klasse zählt die Zeit des Aufblitzens; der Einbau folgt später.

## Dateien
- `scripts/hit_flash.gd`: neu
- `tests/test_hit_flash.gd`: neu

## Akzeptanzkriterien
`scripts/hit_flash.gd` genau so:
```gdscript
class_name HitFlash
extends RefCounted
## Kurzes rotes Aufblitzen nach einem Treffer.

const DURATION := 0.25
const COLOR := Color(1.0, 0.25, 0.2)
const MAX_ALPHA := 0.5

var time_left := 0.0


func trigger() -> void:
	time_left = DURATION


func tick(delta: float) -> void:
	time_left = maxf(0.0, time_left - delta)


## Stärke von 1 (gerade getroffen) bis 0 (vorbei).
func amount() -> float:
	return time_left / DURATION


func is_active() -> bool:
	return time_left > 0.0


## Farbe der Überlagerung mit passender Deckkraft.
func overlay_color() -> Color:
	var c := COLOR
	c.a = MAX_ALPHA * amount()
	return c
```

## Tests
`tests/test_hit_flash.gd` mit `extends "res://tests/base_test.gd"`, `var f: HitFlash`; `setup()`: `f = HitFlash.new()`.
- `test_ruhe`: `f.amount()` ist 0.0; `f.is_active()` falsch; `f.overlay_color().a` ist 0.0
- `test_treffer`: `f.trigger()` → `f.amount()` ist 1.0; `f.is_active()` wahr; `f.overlay_color().a` ist 0.5
- `test_abklingen`: `f.trigger()`, `f.tick(0.125)` → `f.amount()` ist 0.5; `f.tick(1.0)` → `f.amount()` ist 0.0; `f.is_active()` falsch
- `test_erneut`: `f.trigger()`, `f.tick(0.2)`, `f.trigger()` → `f.amount()` ist 1.0

Review (16.10.2026): gemergt.
