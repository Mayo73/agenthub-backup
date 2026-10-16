extends "res://tests/base_test.gd"


func test_alle() -> void:
	var a := CellSounds.all()
	check_eq(a.size(), 8, "a.size() ist 8")
	check(a.has("wachsen"), "a.has(\"wachsen\") wahr")
	for v in a.values():
		check(v is AudioStreamWAV, "v is AudioStreamWAV wahr")
		check((v as AudioStreamWAV).loop_mode == AudioStreamWAV.LOOP_DISABLED, "loop_mode == LOOP_DISABLED")


func test_laengen() -> void:
	check_eq(CellSounds.eat_plant().data.size(), int(0.12 * SoundSynth.MIX_RATE) * 2, "eat_plant Datenlänge korrekt")
	check_eq(CellSounds.grow().data.size(), int(0.6 * SoundSynth.MIX_RATE) * 2, "grow Datenlänge korrekt")


func test_wasser() -> void:
	var w := CellSounds.water_loop()
	check(w.loop_mode == AudioStreamWAV.LOOP_FORWARD, "w.loop_mode == LOOP_FORWARD")
	check_eq(w.loop_end, int(2.0 * SoundSynth.MIX_RATE), "w.loop_end ist 2.0 * MIX_RATE")


func test_nicht_stumm() -> void:
	var data := CellSounds.hit().data
	var i := 0
	while i < data.size():
		if data[i] != 0:
			break
		i += 1
	check(i < data.size(), "mindestens ein Byte ungleich 0")
