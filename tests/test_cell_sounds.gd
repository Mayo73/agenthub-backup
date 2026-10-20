extends "res://tests/base_test.gd"


func test_alle() -> void:
	var a := CellSounds.all()
	check_eq(a.size(), 10, "a.size() ist 10")
	check(a.has("wachsen"), "a.has(\"wachsen\") wahr")
	check(a.has("zuschnappen"), "a.has(\"zuschnappen\") wahr")
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


func test_fressen_und_biss() -> void:
	check_eq(CellSounds.eat_meat().data.size(), (int(0.17 * SoundSynth.MIX_RATE) + int(0.05 * SoundSynth.MIX_RATE)) * 2, "Schlucken mit Bläschen dauert 0,22 s")
	check_eq(CellSounds.bite().data.size(), int(0.09 * SoundSynth.MIX_RATE) * 2, "Zuschnappen dauert 0,09 s")
	check_eq(CellSounds.delayed(PackedFloat32Array([0.5]), 0.01).size(), int(0.01 * SoundSynth.MIX_RATE) + 1, "Stille davor")


func test_verwandlung() -> void:
	var a := CellSounds.all()
	check(a.has("verwandlung"), "Klang verwandlung vorhanden")
	var length := (a["verwandlung"] as AudioStreamWAV).get_length()
	check(length > 2.3 and length < 2.7, "Dauer zwischen 2,3 und 2,7 Sekunden (%.2f s)" % length)
