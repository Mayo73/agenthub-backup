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
