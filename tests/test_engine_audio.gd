extends "res://tests/base_test.gd"

func test_tonhoehe() -> void:
	check(absf(EngineAudio.pitch_for(0.0, 760.0) - 0.6) < 0.001, "pitch for speed=0 ist MIN_PITCH")
	check(absf(EngineAudio.pitch_for(760.0, 760.0) - 2.0) < 0.001, "pitch for max_speed ist MAX_PITCH")
	check(absf(EngineAudio.pitch_for(380.0, 760.0) - 1.3) < 0.001, "pitch for half speed ist 1.3")
	check(absf(EngineAudio.pitch_for(1000.0, 760.0) - 2.0) < 0.001, "pitch für speed > max_speed ist MAX_PITCH")
	check(absf(EngineAudio.pitch_for(100.0, 0.0) - 0.6) < 0.001, "pitch für max_speed=0 ist MIN_PITCH")


func test_motorlautstaerke() -> void:
	check(absf(EngineAudio.engine_db(0.0) + 16.0) < 0.001, "engine_db ohne Gas ist -16 dB")
	check(absf(EngineAudio.engine_db(1.0) + 6.0) < 0.001, "engine_db bei Vollgas ist -6 dB")
	check(absf(EngineAudio.engine_db(0.5) + 11.0) < 0.001, "engine_db bei halb Gas ist -11 dB")


func test_quietschen() -> void:
	check(absf(EngineAudio.squeal_db(false, 30.0) + 80.0) < 0.001, "squeal_db ohne Drift ist SILENT_DB")
	check(absf(EngineAudio.squeal_db(true, 12.0) + 18.0) < 0.001, "squeal_db bei 12° ist -18 dB")
	check(absf(EngineAudio.squeal_db(true, 45.0) + 6.0) < 0.001, "squeal_db bei 45° ist -6 dB")
	check(absf(EngineAudio.squeal_db(true, -45.0) + 6.0) < 0.001, "squeal_db bei -45° ist -6 dB")
	check(absf(EngineAudio.squeal_db(true, 90.0) + 6.0) < 0.001, "squeal_db bei 90° ist -6 dB")
