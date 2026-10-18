---
id: T-0285
title: FishSounds – Klänge für Biss und Verbesserung in der Fischphase
project: zellenphase
priority: 4
---
## Ziel
Meilenstein „Fischphase – Optik, Klang, Speichern und Abnahme“, Teil „Klänge“: Die Fischphase nutzt die Klänge der Zellenphase (`CellSounds`) und bekommt zwei eigene dazu: einen Biss und eine Verbesserung im Entwicklungsmenü. Wie alle Klänge werden sie mit `SoundSynth` erzeugt, ohne Audiodateien. Eingebaut werden sie in T-0286.

## Dateien
- `scripts/fish_sounds.gd` – neu
- `tests/test_fish_sounds.gd` – neu

## Akzeptanzkriterien
Neue Datei `scripts/fish_sounds.gd`, genau so:
```gdscript
class_name FishSounds
extends RefCounted
## Zusätzliche Klänge der Fischphase, mit SoundSynth erzeugt (keine Audiodateien).


## Biss: kurzes, tiefes Knacken.
static func bite() -> AudioStreamWAV:
	var crack := SoundSynth.lowpass(SoundSynth.noise(0.12, 0.7, 23), 0.35)
	var low := SoundSynth.sweep(220.0, 90.0, 0.12, SoundSynth.Wave.SINE, 0.4)
	return SoundSynth.make_stream(SoundSynth.fade_out(SoundSynth.mix(crack, low)), false)


## Verbesserung: drei schnell steigende Töne.
static func upgrade() -> AudioStreamWAV:
	var a := SoundSynth.tone(523.0, 0.12, SoundSynth.Wave.SINE, 0.35)
	var b := SoundSynth.tone(659.0, 0.12, SoundSynth.Wave.SINE, 0.35)
	var c := SoundSynth.tone(784.0, 0.25, SoundSynth.Wave.SINE, 0.35)
	var out := PackedFloat32Array()
	out.append_array(a)
	out.append_array(b)
	out.append_array(c)
	return SoundSynth.make_stream(SoundSynth.fade_out(out), false)


## Klänge nach Namen; werden in der Fischszene zu GameAudio.streams hinzugefügt.
static func all() -> Dictionary:
	return {"biss": bite(), "verbessern": upgrade()}
```

## Tests
`tests/test_fish_sounds.gd` (neu, `extends "res://tests/base_test.gd"`):
- `test_namen`: `FishSounds.all().keys()` sortiert ist `["biss", "verbessern"]`
- `test_biss`: `var s := FishSounds.bite()`; `s.loop_mode` ist `AudioStreamWAV.LOOP_DISABLED`; `s.data.size() > 0` wahr; `s.mix_rate` ist `SoundSynth.MIX_RATE`
- `test_verbessern_laenger_als_biss`: `FishSounds.upgrade().data.size() > FishSounds.bite().data.size()` wahr
- `test_keine_namensgleichheit`: kein Schlüssel aus `FishSounds.all()` ist auch ein Schlüssel von `CellSounds.all()`

Review (18.10.2026): gemergt.
