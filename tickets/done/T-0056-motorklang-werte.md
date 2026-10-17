---
id: T-0056
title: Klangwerte aus dem Fahrzustand (EngineAudio)
project: drift
priority: 3
---
## Ziel
Eine reine Rechenklasse übersetzt den Fahrzustand in Klangwerte: Tonhöhe des Motors nach Tempo, Lautstärke nach Gas und Lautstärke des Reifenquietschens nach Driftwinkel. Abgespielt wird in einem späteren Ticket.

## Dateien
- `scripts/engine_audio.gd`: neu, beginnt mit `class_name EngineAudio` und `extends RefCounted`
- `tests/test_engine_audio.gd`: neu

## Akzeptanzkriterien
Genau dieser Code in `scripts/engine_audio.gd`:
```gdscript
class_name EngineAudio
extends RefCounted
## Rechnet den Fahrzustand in Klangwerte um (Tonhöhe, Lautstärke). Spielt selbst nichts ab.

const MIN_PITCH := 0.6
const MAX_PITCH := 2.0
const SILENT_DB := -80.0


## Tonhöhe des Motors: MIN_PITCH im Stand, MAX_PITCH bei Höchsttempo (und darüber).
static func pitch_for(speed: float, max_speed: float) -> float:
	if max_speed <= 0.0:
		return MIN_PITCH
	return lerpf(MIN_PITCH, MAX_PITCH, clampf(speed / max_speed, 0.0, 1.0))


## Motorlautstärke: -16 dB ohne Gas, -6 dB bei Vollgas.
static func engine_db(throttle: float) -> float:
	return lerpf(-16.0, -6.0, clampf(throttle, 0.0, 1.0))


## Reifenquietschen: still ohne Drift; im Drift -18 dB bei 12° Schräglauf bis -6 dB ab 45°.
static func squeal_db(drifting: bool, slip_angle_deg: float) -> float:
	if not drifting:
		return SILENT_DB
	var t := clampf((absf(slip_angle_deg) - 12.0) / 33.0, 0.0, 1.0)
	return lerpf(-18.0, -6.0, t)
```

## Tests
Neue Datei `tests/test_engine_audio.gd` mit `extends "res://tests/base_test.gd"`. Alle Vergleiche mit `absf(ist - soll) < 0.001`:
- `test_tonhoehe`: `EngineAudio.pitch_for(0.0, 760.0)` ist 0.6; `pitch_for(760.0, 760.0)` ist 2.0; `pitch_for(380.0, 760.0)` ist 1.3; `pitch_for(1000.0, 760.0)` ist 2.0; `pitch_for(100.0, 0.0)` ist 0.6
- `test_motorlautstaerke`: `EngineAudio.engine_db(0.0)` ist -16.0; `engine_db(1.0)` ist -6.0; `engine_db(0.5)` ist -11.0
- `test_quietschen`: `EngineAudio.squeal_db(false, 30.0)` ist -80.0; `squeal_db(true, 12.0)` ist -18.0; `squeal_db(true, 45.0)` ist -6.0; `squeal_db(true, -45.0)` ist -6.0; `squeal_db(true, 90.0)` ist -6.0

Review (16.10.2026): gemergt.
