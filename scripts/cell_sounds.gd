class_name CellSounds
extends RefCounted
## Klänge der Zellenphase, alle mit SoundSynth erzeugt (keine Audiodateien).


## Pflanzen fressen: kurzer, steigender Ton.
static func eat_plant() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.fade_out(SoundSynth.sweep(500.0, 900.0, 0.12, SoundSynth.Wave.SINE, 0.4)), false)


## Fleisch oder eine ganze Zelle fressen: kurzes Schmatzen, weiches Schlucken, ein Bläschen danach.
## (Neu gestaltet am 19.10.2026, weil das alte Rauschen dem Nutzer nicht gefiel.)
static func eat_meat() -> AudioStreamWAV:
	var smack := SoundSynth.fade_out(SoundSynth.lowpass(SoundSynth.noise(0.05, 0.5, 5), 0.25))
	var gulp := SoundSynth.fade_out(SoundSynth.sweep(260.0, 110.0, 0.16, SoundSynth.Wave.SINE, 0.45))
	var bubble := SoundSynth.fade_out(SoundSynth.sweep(700.0, 1200.0, 0.05, SoundSynth.Wave.SINE, 0.12))
	return SoundSynth.make_stream(SoundSynth.mix(SoundSynth.mix(smack, delayed(gulp, 0.03)), delayed(bubble, 0.17)), false)


## Die Spielerzelle beißt zu: kurzes, dumpfes Zuschnappen (weicher als der Treffer, den sie selbst abbekommt).
static func bite() -> AudioStreamWAV:
	var snap := SoundSynth.fade_out(SoundSynth.lowpass(SoundSynth.noise(0.04, 0.5, 9), 0.35))
	var thud := SoundSynth.fade_out(SoundSynth.sweep(200.0, 120.0, 0.09, SoundSynth.Wave.SINE, 0.4))
	return SoundSynth.make_stream(SoundSynth.mix(snap, thud), false)


## Verschiebt einen Klang um seconds nach hinten (Stille davor).
static func delayed(samples: PackedFloat32Array, seconds: float) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(int(seconds * SoundSynth.MIX_RATE))
	out.fill(0.0)
	out.append_array(samples)
	return out


## Treffer: fallender, rauer Ton.
static func hit() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.fade_out(SoundSynth.sweep(300.0, 120.0, 0.2, SoundSynth.Wave.SQUARE, 0.3)), false)


## Wachstum: zwei steigende Töne.
static func grow() -> AudioStreamWAV:
	var a := SoundSynth.sweep(300.0, 900.0, 0.6, SoundSynth.Wave.SINE, 0.35)
	var b := SoundSynth.sweep(450.0, 1350.0, 0.6, SoundSynth.Wave.SINE, 0.15)
	return SoundSynth.make_stream(SoundSynth.fade_out(SoundSynth.mix(a, b)), false)


## Tod: langer, fallender Ton.
static func death() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.fade_out(SoundSynth.sweep(400.0, 80.0, 0.8, SoundSynth.Wave.SAW, 0.3)), false)


## Klick für Menüknöpfe.
static func click() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.tone(880.0, 0.05, SoundSynth.Wave.SINE, 0.3), false)


## Teil im Editor eingebaut.
static func place_part() -> AudioStreamWAV:
	var a := SoundSynth.tone(520.0, 0.08, SoundSynth.Wave.SINE, 0.3)
	var b := SoundSynth.tone(780.0, 0.08, SoundSynth.Wave.SINE, 0.2)
	return SoundSynth.make_stream(SoundSynth.mix(a, b), false)


## Teil im Editor entfernt.
static func remove_part() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.fade_out(SoundSynth.sweep(600.0, 300.0, 0.1, SoundSynth.Wave.SINE, 0.3)), false)


## Wasserrauschen, 2 Sekunden, Schleife.
static func water_loop() -> AudioStreamWAV:
	return SoundSynth.make_stream(SoundSynth.lowpass(SoundSynth.noise(2.0, 0.5, 11), 0.05), true)


## Alle Einzelklänge nach Namen (ohne das Wasserrauschen).
static func all() -> Dictionary:
	return {
		"fressen_pflanze": eat_plant(),
		"fressen_fleisch": eat_meat(),
		"zuschnappen": bite(),
		"treffer": hit(),
		"wachsen": grow(),
		"tod": death(),
		"klick": click(),
		"teil_setzen": place_part(),
		"teil_entfernen": remove_part(),
	}
