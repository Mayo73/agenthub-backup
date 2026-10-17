---
id: T-0055
title: Hintergrundmusik im Code erzeugen (MusicSynth)
project: drift
priority: 3
after: T-0053
---
## Ziel
Eine kurze Musikschleife im Chiptune-Stil, erzeugt aus Notenlisten: Melodie und Bass werden gemischt und als Schleife abgespielt.

## Dateien
- `scripts/music_synth.gd`: neu, beginnt mit `class_name MusicSynth` und `extends RefCounted`
- `tests/test_music_synth.gd`: neu

## Akzeptanzkriterien
Genau dieser Code in `scripts/music_synth.gd`:
```gdscript
class_name MusicSynth
extends RefCounted
## Erzeugt die Hintergrundmusik aus Notenlisten (MIDI-Nummern, REST = Pause).

const REST := -1
const NOTE_LEN := 0.2

const THEME_LEAD := [
	57, 60, 64, 67, 64, 60, 62, 64,
	57, 60, 64, 69, 67, 64, 62, REST,
	53, 57, 60, 65, 64, 60, 57, 60,
	55, 59, 62, 67, 65, 62, 59, REST,
]
const THEME_BASS := [
	45, REST, 45, REST, 45, REST, 45, REST,
	45, REST, 45, REST, 45, REST, 43, REST,
	41, REST, 41, REST, 41, REST, 41, REST,
	43, REST, 43, REST, 43, REST, 43, REST,
]


## Frequenz einer MIDI-Note (69 = A4 = 440 Hz).
static func midi_to_freq(note: int) -> float:
	return 440.0 * pow(2.0, (note - 69) / 12.0)


## Reiht Noten gleicher Länge aneinander. REST ergibt Stille.
static func melody(notes: Array, note_len: float, wave: int = SoundSynth.Wave.SQUARE, volume: float = 0.2) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	var n := int(note_len * SoundSynth.MIX_RATE)
	for note in notes:
		if note == REST:
			var silence := PackedFloat32Array()
			silence.resize(n)
			out.append_array(silence)
		else:
			out.append_array(SoundSynth.tone(midi_to_freq(note), note_len, wave, volume))
	return out


## Die Musikschleife des Spiels (32 Noten, etwa 6,4 Sekunden).
static func theme() -> AudioStreamWAV:
	var lead := melody(THEME_LEAD, NOTE_LEN, SoundSynth.Wave.SQUARE, 0.12)
	var bass := melody(THEME_BASS, NOTE_LEN, SoundSynth.Wave.SAW, 0.15)
	return SoundSynth.make_stream(SoundSynth.mix(lead, bass), true)
```

## Tests
Neue Datei `tests/test_music_synth.gd` mit `extends "res://tests/base_test.gd"`:
- `test_notenfrequenz`: `absf(MusicSynth.midi_to_freq(69) - 440.0) < 0.01`, `absf(MusicSynth.midi_to_freq(81) - 880.0) < 0.01`, `absf(MusicSynth.midi_to_freq(57) - 220.0) < 0.01`
- `test_melodie_mit_pause`: `var m := MusicSynth.melody([69, MusicSynth.REST], 0.1)` → `m.size()` ist `2 * int(0.1 * SoundSynth.MIX_RATE)`; `m[int(0.1 * SoundSynth.MIX_RATE) + 100]` ist 0.0; `absf(m[500]) > 0.1`
- `test_thema`: `var s := MusicSynth.theme()` → `s.loop_mode` ist `AudioStreamWAV.LOOP_FORWARD`; `s.data.size()` ist `32 * int(MusicSynth.NOTE_LEN * SoundSynth.MIX_RATE) * 2`; `MusicSynth.THEME_LEAD.size()` ist 32 und `MusicSynth.THEME_BASS.size()` ist 32

Review (16.10.2026): gemergt.
