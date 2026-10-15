extends "res://tests/base_test.gd"


func test_sinus() -> void:
	check(absf(SoundSynth.wave_value(SoundSynth.Wave.SINE, 0.25) - 1.0) < 0.001, "Sinus bei 0.25 sollte ~1.0 sein")
	check(absf(SoundSynth.wave_value(SoundSynth.Wave.SINE, 0.0)) < 0.001, "Sinus bei 0.0 sollte ~0.0 sein")


func test_rechteck() -> void:
	check(SoundSynth.wave_value(SoundSynth.Wave.SQUARE, 0.25) == 1.0, "Rechteck bei 0.25 sollte 1.0 sein")
	check(SoundSynth.wave_value(SoundSynth.Wave.SQUARE, 0.75) == -1.0, "Rechteck bei 0.75 sollte -1.0 sein")
	check(SoundSynth.wave_value(SoundSynth.Wave.SQUARE, 1.25) == 1.0, "Rechteck bei 1.25 sollte 1.0 sein (modulare Phase)")


func test_saegezahn() -> void:
	check(SoundSynth.wave_value(SoundSynth.Wave.SAW, 0.0) == -1.0, "Sägezahn bei 0.0 sollte -1.0 sein")
	check(SoundSynth.wave_value(SoundSynth.Wave.SAW, 0.5) == 0.0, "Sägezahn bei 0.5 sollte 0.0 sein")


func test_pcm16() -> void:
	var b := SoundSynth.to_pcm16(PackedFloat32Array([1.0, -1.0, 0.0, 2.0]))
	check(b.size() == 8, "PCM sollte 8 Bytes haben (4 Samples * 2)")
	check(b.decode_s16(0) == 32767, "PCM bei 1.0 sollte 32767 sein")
	check(b.decode_s16(2) == -32767, "PCM bei -1.0 sollte -32767 sein")
	check(b.decode_s16(4) == 0, "PCM bei 0.0 sollte 0 sein")
	check(b.decode_s16(6) == 32767, "PCM bei 2.0 (geclamped auf 1.0) sollte 32767 sein")


func test_stream_ohne_schleife() -> void:
	var s := SoundSynth.make_stream(PackedFloat32Array([0.0, 0.5, -0.5]), false)
	check(s.data.size() == 6, "Stream ohne Loop sollte 6 Bytes haben (3 Samples * 2)")
	check(s.mix_rate == 22050, "Stream mix_rate sollte 22050 sein")
	check(s.format == AudioStreamWAV.FORMAT_16_BITS, "Stream format sollte 16-Bit sein")
	check(s.loop_mode == AudioStreamWAV.LOOP_DISABLED, "Stream ohne Loop sollte LOOP_DISABLED haben")


func test_stream_mit_schleife() -> void:
	var samples := PackedFloat32Array()
	samples.resize(100)
	var s := SoundSynth.make_stream(samples, true)
	check(s.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Stream mit Loop sollte LOOP_FORWARD haben")
	check(s.loop_end == 100, "Stream loop_end sollte 100 sein (Samplesize)")


func test_ton_laenge() -> void:
	var t := SoundSynth.tone(441.0, 0.1)
	check(t.size() == 2205, "Tongröße bei 0.1s sollte 2205 Samples sein (0.1 * 22050)")


func test_ton_lautstaerke() -> void:
	var t := SoundSynth.tone(441.0, 0.1, SoundSynth.Wave.SQUARE, 0.3)
	var m := 0.0
	for v in t:
		m = maxf(m, absf(v))
	check(m <= 0.3001 and m >= 0.29, "Maximale Lautstärke sollte bei 0.3 liegen (hat $m$)")
	check(t[0] == 0.0, "Erster Sample bei eingeblendetem Ton sollte 0.0 sein")


func test_ton_ohne_blende() -> void:
	var t := SoundSynth.tone(441.0, 0.1, SoundSynth.Wave.SQUARE, 0.3, false)
	check(absf(t[0] - 0.3) < 0.0001, "Bei fade=false sollte t[0] == 0.3 sein (hat absf(t[0]) = $m$)")


func test_rauschen() -> void:
	var a := SoundSynth.noise(0.05, 0.5, 3)
	var b := SoundSynth.noise(0.05, 0.5, 3)
	var c := SoundSynth.noise(0.05, 0.5, 4)
	check(a == b, "Gleicher seed_value muss gleiches Rauschen ergeben")
	check(a != c, "Unterschiedlicher seed_value muss unterschiedliches Rauschen ergeben")
	check(a.size() == int(0.05 * SoundSynth.MIX_RATE), "Rauschen Länge sollte 1102 Samples sein (0.05 * 22050)")


func test_mischen() -> void:
	var m := SoundSynth.mix(PackedFloat32Array([0.1, 0.2, 0.3]), PackedFloat32Array([0.5]))
	check(m.size() == 3, "Mixed sollte 3 Samples haben (max(3,1))")
	check(absf(m[0] - 0.6) < 0.0001, "m[0] sollte 0.1+0.5=0.6 sein (hat $m$)")
	check(absf(m[2] - 0.3) < 0.0001, "m[2] sollte 0.3+0=0.3 sein (hat $m$)")
