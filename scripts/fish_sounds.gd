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
