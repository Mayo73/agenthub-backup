class_name CellMusic
extends RefCounted
## Ruhige Hintergrundmusik der Zellenphase (Unterwasser-Stimmung), aus Notenlisten (MIDI-Nummern).

const NOTE_LEN := 0.5
const REST := -1
const LEAD := [
	64, REST, 67, 71, 69, REST, 67, 64,
	62, REST, 64, 67, 66, REST, 62, REST,
	60, REST, 64, 67, 71, REST, 69, 67,
	64, REST, 62, 64, 59, REST, REST, REST,
]
const BASS := [
	40, REST, REST, REST, 47, REST, REST, REST,
	38, REST, REST, REST, 45, REST, REST, REST,
	36, REST, REST, REST, 43, REST, REST, REST,
	40, REST, REST, REST, 47, REST, REST, REST,
]


## Die Musikschleife: 32 Noten zu 0,5 Sekunden = 16 Sekunden, weich gefiltert.
static func theme() -> AudioStreamWAV:
	var lead := MusicSynth.melody(LEAD, NOTE_LEN, SoundSynth.Wave.SINE, 0.12)
	var bass := MusicSynth.melody(BASS, NOTE_LEN, SoundSynth.Wave.SINE, 0.18)
	return SoundSynth.make_stream(SoundSynth.lowpass(SoundSynth.mix(lead, bass), 0.3), true)
