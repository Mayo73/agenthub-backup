extends "res://tests/base_test.gd"


func test_sweep_laenge() -> void:
	var s := SoundSynth.sweep(100.0, 200.0, 0.5)
	check_eq(s.size(), int(0.5 * SoundSynth.MIX_RATE), "sweep hat richtige Länge")


func test_sweep_start_und_lautstaerke() -> void:
	var s := SoundSynth.sweep(440.0, 880.0, 0.1, SoundSynth.Wave.SINE, 0.5)
	check_eq(s[0], 0.0, "s[0] ist 0.0")
	for v in s:
		check(absf(v) <= 0.5001, "alle Werte abs(v) <= 0.5001")


func test_sweep_frequenz() -> void:
	var s := SoundSynth.sweep(1000.0, 1000.0, 1.0, SoundSynth.Wave.SQUARE, 1.0)
	var wechsel := 0
	for i in range(1, s.size()):
		if s[i] != s[i - 1]:
			wechsel += 1
	check(absi(wechsel - 2000) <= 4, "wechsel " + str(wechsel) + " nahe 2000")


func test_ausblenden() -> void:
	var t := SoundSynth.tone(440.0, 0.1, SoundSynth.Wave.SQUARE, 0.5, false)
	var f := SoundSynth.fade_out(t)
	check_eq(f.size(), t.size(), "fade_out behält Länge")
	check_eq(f[0], 0.5, "f[0] ist 0.5")
	check_eq(f[f.size() - 1], 0.0, "letzter Wert ist 0.0")
	check_eq(t[0], 0.5, "t[0] unverändert (Eingabe nicht geändert)")


func test_tiefpass_konstant() -> void:
	var c := PackedFloat32Array()
	for i in range(100):
		c.append(1.0)
	var l := SoundSynth.lowpass(c, 0.5)
	check_eq(l[0], 0.5, "l[0] ist 0.5")
	check_eq(l[1], 0.75, "l[1] ist 0.75")
	check(l[99] > 0.999, "l[99] > 0.999")


func test_tiefpass_glaettet() -> void:
	var n := SoundSynth.noise(0.5, 0.5, 3)
	var l := SoundSynth.lowpass(n, 0.05)
	var sum_n := 0.0
	var sum_l := 0.0
	for v in n:
		sum_n += absf(v)
	for v in l:
		sum_l += absf(v)
	check(sum_l < sum_n * 0.5, "Summe Beträge von l ist kleiner als Hälfte von n")
