---
id: T-0172
title: Augen mit Pupille und Blinzeln (EyeLook)
project: zellenphase
priority: 2
---
## Ziel
Augen sollen lebendig wirken: Die Pupille schaut in eine Richtung, die Augen blinzeln ab und zu, das Stielauge sitzt auf einem Stiel weiter außen. Diese Klasse rechnet nur; gezeichnet wird in späteren Tickets.

## Dateien
- `scripts/eye_look.gd`: neu
- `tests/test_eye_look.gd`: neu

## Akzeptanzkriterien
`scripts/eye_look.gd` genau so:
```gdscript
class_name EyeLook
extends RefCounted
## Augen: Lage, Größe, Blickrichtung der Pupille und Blinzeln.

const PUPIL_RANGE := 0.45
const BLINK_PERIOD := 4.0
const BLINK_TIME := 0.15
const STALK_FACTOR := 1.35


## Lage der Pupille relativ zur Augenmitte; look_dir in Zellkoordinaten (Länge beliebig).
static func pupil_offset(look_dir: Vector2, eye_radius: float) -> Vector2:
	if look_dir.length() < 0.001:
		return Vector2.ZERO
	return look_dir.normalized() * eye_radius * PUPIL_RANGE


## 1 = offen, 0,1 = zu. phase verschiebt das Blinzeln, damit nicht alle Augen gleichzeitig blinzeln.
static func openness(time: float, phase: float = 0.0) -> float:
	var t := fposmod(time + phase, BLINK_PERIOD)
	return 0.1 if t < BLINK_TIME else 1.0


## Augenmitte in Pixeln relativ zur Zellmitte; das Stielauge sitzt weiter außen.
static func eye_center(part: Dictionary, radius: float) -> Vector2:
	var pos: Vector2 = part["pos"]
	if part["id"] == "stielauge":
		return pos * radius * STALK_FACTOR
	return pos * radius


static func eye_radius(id: String, radius: float) -> float:
	return radius * (0.18 if id == "stielauge" else 0.13)
```

## Tests
`tests/test_eye_look.gd` mit `extends "res://tests/base_test.gd"`:
- `test_pupille`: `EyeLook.pupil_offset(Vector2(10, 0), 1.0).is_equal_approx(Vector2(0.45, 0))` wahr; `EyeLook.pupil_offset(Vector2(0, -3), 2.0).is_equal_approx(Vector2(0, -0.9))` wahr; `EyeLook.pupil_offset(Vector2.ZERO, 1.0) == Vector2.ZERO` wahr
- `test_blinzeln`: `EyeLook.openness(0.05)` ist 0.1; `EyeLook.openness(1.0)` ist 1.0; `EyeLook.openness(4.05)` ist 0.1; `EyeLook.openness(0.05, 1.0)` ist 1.0
- `test_lage`: `EyeLook.eye_center({"id": "knopfauge", "pos": Vector2(0.5, 0.3)}, 10.0).is_equal_approx(Vector2(5, 3))` wahr; `EyeLook.eye_center({"id": "stielauge", "pos": Vector2(1, 0)}, 10.0).is_equal_approx(Vector2(13.5, 0))` wahr
- `test_groesse`: `EyeLook.eye_radius("stielauge", 10.0)` ist 1.8; `EyeLook.eye_radius("knopfauge", 10.0)` ist 1.3

Review (16.10.2026): gemergt.
