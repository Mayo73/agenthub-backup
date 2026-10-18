---
id: T-0314
title: FishMusic – eigene Musik für die Fischphase
project: zellenphase
priority: 3
---
## Ziel
Auftrag „Fischphase – lebendige Welt“: Die Fischphase spielt bisher die Musik der Zellenphase. Sie bekommt eine eigene, ruhigere und tiefere Musikschleife, erzeugt wie `CellMusic` aus Notenlisten (keine Audiodateien). Einbau in T-0315.

## Dateien
- `scripts/fish_music.gd` – neu
- `tests/test_fish_music.gd` – neu

## Akzeptanzkriterien
Neue Datei `scripts/fish_music.gd`, genau so:
```gdscript
class_name FishMusic
extends RefCounted
## Hintergrundmusik der Fischphase: langsamer und tiefer als die Zellenphase (Weite des Meeres).

const NOTE_LEN := 0.6
const REST := -1
const LEAD := [
	57, REST, 60, 64, 62, REST, REST, 60,
	57, REST, 55, 57, 60, REST, REST, REST,
	53, REST, 57, 60, 64, REST, 62, 60,
	57, REST, 55, 52, 57, REST, REST, REST,
]
const BASS := [
	33, REST, REST, REST, 40, REST, REST, REST,
	31, REST, REST, REST, 38, REST, REST, REST,
	29, REST, REST, REST, 36, REST, REST, REST,
	33, REST, REST, REST, 28, REST, REST, REST,
]


## Die Musikschleife: 32 Noten zu 0,6 Sekunden = 19,2 Sekunden, stark weich gefiltert.
static func theme() -> AudioStreamWAV:
	var lead := MusicSynth.melody(LEAD, NOTE_LEN, SoundSynth.Wave.SINE, 0.11)
	var bass := MusicSynth.melody(BASS, NOTE_LEN, SoundSynth.Wave.SINE, 0.2)
	return SoundSynth.make_stream(SoundSynth.lowpass(SoundSynth.mix(lead, bass), 0.22), true)
```

## Tests
`tests/test_fish_music.gd` (neu, `extends "res://tests/base_test.gd"`):
- `test_gleich_lang`: `FishMusic.LEAD.size()` ist 32 und gleich `FishMusic.BASS.size()`
- `test_schleife`: `var s := FishMusic.theme()`; `s.loop_mode` ist **nicht** `AudioStreamWAV.LOOP_DISABLED`; `s.data.size() > 0` wahr
- `test_laenger_als_zellmusik`: `FishMusic.theme().data.size() > CellMusic.theme().data.size()` wahr
- `test_tiefer`: der kleinste Wert in `FishMusic.BASS` (ohne `REST`) ist kleiner als der kleinste Wert in `CellMusic.BASS` (ohne `REST`)

Review (18.10.2026): gemergt.
