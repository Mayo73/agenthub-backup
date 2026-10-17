---
id: T-0054
title: Fertige Spielklänge (SoundBank)
project: drift
priority: 3
after: T-0053
---
## Ziel
Eine Sammlung fertiger Klänge für das Spiel, alle aus `SoundSynth` erzeugt: Motor (Schleife), Reifenquietschen (Schleife), Menüklick und zwei Countdown-Töne.

## Dateien
- `scripts/sound_bank.gd`: neu, beginnt mit `class_name SoundBank` und `extends RefCounted`
- `tests/test_sound_bank.gd`: neu

## Akzeptanzkriterien
Genau dieser Code in `scripts/sound_bank.gd`:
```gdscript
class_name SoundBank
extends RefCounted
## Fertige Spielklänge, alle mit SoundSynth erzeugt.


## Motorbrummen, 1 Sekunde, nahtlose Schleife (ganze Schwingungen, ohne Blende).
static func engine_loop() -> AudioStreamWAV:
	var low := SoundSynth.tone(55.0, 1.0, SoundSynth.Wave.SAW, 0.35, false)
	var high := SoundSynth.tone(110.0, 1.0, SoundSynth.Wave.SQUARE, 0.12, false)
	return SoundSynth.make_stream(SoundSynth.mix(low, high), true)


## Reifenquietschen, 0,5 Sekunden, Schleife.
static func squeal_loop() -> AudioStreamWAV:
	var whine := SoundSynth.tone(1250.0, 0.5, SoundSynth.Wave.SINE, 0.25, false)
	var hiss := SoundSynth.noise(0.5, 0.08, 7)
	return SoundSynth.make_stream(SoundSynth.mix(whine, hiss), true)


## Kurzer Klick für Menüknöpfe.
static func click() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.tone(880.0, 0.05, SoundSynth.Wave.SQUARE, 0.25), false)


## Countdown-Ton für 3, 2, 1.
static func beep() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.tone(660.0, 0.15, SoundSynth.Wave.SINE, 0.5), false)


## Höherer, längerer Ton bei „Los!“.
static func go_beep() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.tone(990.0, 0.4, SoundSynth.Wave.SINE, 0.5), false)
```

## Tests
Neue Datei `tests/test_sound_bank.gd` mit `extends "res://tests/base_test.gd"`:
- `test_motor`: `var s := SoundBank.engine_loop()` → `s.loop_mode` ist `AudioStreamWAV.LOOP_FORWARD`, `s.data.size()` ist `SoundSynth.MIX_RATE * 2`
- `test_quietschen`: `var s := SoundBank.squeal_loop()` → `s.loop_mode` ist `AudioStreamWAV.LOOP_FORWARD`, `s.data.size()` ist `int(0.5 * SoundSynth.MIX_RATE) * 2`
- `test_klick`: `var s := SoundBank.click()` → `s.loop_mode` ist `AudioStreamWAV.LOOP_DISABLED`, `s.data.size()` ist `int(0.05 * SoundSynth.MIX_RATE) * 2`
- `test_countdown_toene`: `SoundBank.beep().data.size()` ist `int(0.15 * SoundSynth.MIX_RATE) * 2`; `SoundBank.go_beep().data.size()` ist `int(0.4 * SoundSynth.MIX_RATE) * 2`

Review (16.10.2026): gemergt.
