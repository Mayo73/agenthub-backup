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


## Höherer, längerer Ton bei „Los!".
static func go_beep() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.tone(990.0, 0.4, SoundSynth.Wave.SINE, 0.5), false)
