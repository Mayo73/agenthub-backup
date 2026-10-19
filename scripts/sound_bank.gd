class_name SoundBank
extends RefCounted
## Fertige Spielklänge, mit SoundSynth erzeugt. Ausnahme: das Reifenquietschen ist eine echte Aufnahme.

## „Tires Squealing“ von Mike Koenig (soundbible.com), Lizenz CC BY 3.0; Namensnennung im Hauptmenü
## und in docs/QUELLEN.md. Auf eine nahtlose Schleife von 1,4 s geschnitten (Mono, OGG Vorbis).
const SQUEAL_RECORDING: AudioStreamOggVorbis = preload("res://assets/sounds/reifen_quietschen.ogg")
const SQUEAL_CREDIT := "Reifenquietschen: „Tires Squealing“ von Mike Koenig (soundbible.com), Lizenz CC BY 3.0"


## Motorbrummen, 1 Sekunde, nahtlose Schleife (ganze Schwingungen, ohne Blende).
static func engine_loop() -> AudioStreamWAV:
	var low := SoundSynth.tone(55.0, 1.0, SoundSynth.Wave.SAW, 0.35, false)
	var high := SoundSynth.tone(110.0, 1.0, SoundSynth.Wave.SQUARE, 0.12, false)
	return SoundSynth.make_stream(SoundSynth.mix(low, high), true)


## Reifenquietschen als Schleife: echte Aufnahme (siehe SQUEAL_RECORDING), Wunsch des Nutzers vom 19.10.2026.
static func squeal_loop() -> AudioStream:
	var s := SQUEAL_RECORDING
	s.loop = true
	return s


## Kurzer Klick für Menüknöpfe.
static func click() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.tone(880.0, 0.05, SoundSynth.Wave.SQUARE, 0.25), false)


## Countdown-Ton für 3, 2, 1.
static func beep() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.tone(660.0, 0.15, SoundSynth.Wave.SINE, 0.5), false)


## Höherer, längerer Ton bei „Los!".
static func go_beep() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.tone(990.0, 0.4, SoundSynth.Wave.SINE, 0.5), false)
