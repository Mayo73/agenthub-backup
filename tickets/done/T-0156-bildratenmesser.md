---
id: T-0156
title: Bildrate messen (FpsMeter)
project: zellenphase
priority: 3
---
## Ziel
Für den Leistungstest (Abnahmekriterium 12: im Schnitt mindestens 60 FPS mit 30 KI-Zellen) zählt eine Klasse Bilder und Zeit und liefert Durchschnitt und Minimum.

## Dateien
- `scripts/fps_meter.gd`: neu
- `tests/test_fps_meter.gd`: neu

## Akzeptanzkriterien
`scripts/fps_meter.gd` genau so:
```gdscript
class_name FpsMeter
extends RefCounted
## Zählt Bilder und Zeit für den Leistungstest.

var frames := 0
var elapsed := 0.0
var _min_fps := INF


## Ein Bild mit der Dauer delta in Sekunden; delta <= 0 wird übergangen.
func add_frame(delta: float) -> void:
	if delta <= 0.0:
		return
	frames += 1
	elapsed += delta
	_min_fps = minf(_min_fps, 1.0 / delta)


## Bilder pro Sekunde im Durchschnitt (frames / elapsed); 0 ohne Messung.
func average_fps() -> float:
	if elapsed <= 0.0:
		return 0.0
	return frames / elapsed


## Bildrate des langsamsten Bildes; 0 ohne Messung.
func min_fps() -> float:
	if frames == 0:
		return 0.0
	return _min_fps


func reset() -> void:
	frames = 0
	elapsed = 0.0
	_min_fps = INF
```

## Tests
`tests/test_fps_meter.gd` mit `extends "res://tests/base_test.gd"`, `var m: FpsMeter`; `setup()`: `m = FpsMeter.new()`.
- `test_leer`: `m.average_fps()` ist 0.0; `m.min_fps()` ist 0.0
- `test_gleichmaessig`: 60-mal `m.add_frame(1.0 / 60.0)` → `m.frames` ist 60; `m.elapsed` ist 1.0; `m.average_fps()` ist 60.0; `m.min_fps()` ist 60.0
- `test_minimum`: `m.add_frame(1.0 / 60.0)`, `m.add_frame(1.0 / 30.0)` → `m.min_fps()` ist 30.0; `m.average_fps()` ist 40.0
- `test_null_uebergehen`: `m.add_frame(0.0)`, `m.add_frame(-1.0)` → `m.frames` ist 0
- `test_zuruecksetzen`: `m.add_frame(0.1)`, `m.reset()` → `m.frames` ist 0; `m.min_fps()` ist 0.0

Review (16.10.2026): gemergt.
