extends "res://tests/base_test.gd"


func test_motor() -> void:
	var s := SoundBank.engine_loop()
	check(s.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Motor-Schleife sollte LOOP_FORWARD sein")
	check(s.data.size() == SoundSynth.MIX_RATE * 2, "Motor-Datenlänge sollte MIX_RATE*2 sein (%d)" % [SoundSynth.MIX_RATE * 2])


func test_quietschen() -> void:
	var s := SoundBank.squeal_loop()
	check(s.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Quietschen-Schleife sollte LOOP_FORWARD sein")
	check(s.data.size() == int(0.5 * SoundSynth.MIX_RATE) * 2, "Quietschen-Datenlänge sollte 0.5*SOUND_SYNTH_MIX_RATE*2 sein (%d)" % [int(0.5 * SoundSynth.MIX_RATE) * 2])


func test_klick() -> void:
	var s := SoundBank.click()
	check(s.loop_mode == AudioStreamWAV.LOOP_DISABLED, "Klick sollte LOOP_DISABLED sein")
	check(s.data.size() == int(0.05 * SoundSynth.MIX_RATE) * 2, "Klick-Datenlänge sollte 0.05*MIX_RATE*2 sein (%d)" % [int(0.05 * SoundSynth.MIX_RATE) * 2])


func test_countdown_toene() -> void:
	var beep_size := SoundBank.beep().data.size()
	var expected_beep := int(0.15 * SoundSynth.MIX_RATE) * 2
	check(beep_size == expected_beep, "Countdown-Ton Größe sollte %d sein (hat %d)" % [expected_beep, beep_size])

	var go_beep_size := SoundBank.go_beep().data.size()
	var expected_go := int(0.4 * SoundSynth.MIX_RATE) * 2
	check(go_beep_size == expected_go, "Los-Ton Größe sollte %d sein (hat %d)" % [expected_go, go_beep_size])
