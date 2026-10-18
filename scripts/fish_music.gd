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
