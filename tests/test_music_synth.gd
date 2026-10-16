extends "res://tests/base_test.gd"


func test_notenfrequenz() -> void:
	check(absf(MusicSynth.midi_to_freq(69) - 440.0) < 0.01, "MIDI 69 sollte ~440 Hz sein")
	check(absf(MusicSynth.midi_to_freq(81) - 880.0) < 0.01, "MIDI 81 sollte ~880 Hz sein")
	check(absf(MusicSynth.midi_to_freq(57) - 220.0) < 0.01, "MIDI 57 sollte ~220 Hz sein")


func test_melodie_mit_pause() -> void:
	var m := MusicSynth.melody([69, MusicSynth.REST], 0.1)
	check(m.size() == 2 * int(0.1 * SoundSynth.MIX_RATE), "Länge bei [Note, REST] sollte doppelt so lang sein")
	check(m[int(0.1 * SoundSynth.MIX_RATE) + 100] == 0.0, "Sample nach der Note sollte Stille (0.0) sein")
	check(absf(m[500]) > 0.1, "Sample innerhalb der Note sollte laut genug sein")


func test_thema() -> void:
	var s := MusicSynth.theme()
	check(s.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Theme-Stream sollte LOOP_FORWARD haben")
	check(s.data.size() == 32 * int(MusicSynth.NOTE_LEN * SoundSynth.MIX_RATE) * 2, "Datenlänge von theme()")
	check(MusicSynth.THEME_LEAD.size() == 32, "THEME_LEAD sollte 32 Noten haben")
	check(MusicSynth.THEME_BASS.size() == 32, "THEME_BASS sollte 32 Noten haben")
