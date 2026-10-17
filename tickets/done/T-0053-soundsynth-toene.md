---
id: T-0053
title: Klangerzeugung – Töne, Rauschen, Mischen
project: drift
priority: 3
after: T-0052
---
## Ziel
`SoundSynth` bekommt drei Funktionen, aus denen später alle Spielklänge gebaut werden: einen Ton fester Höhe, Rauschen und das Mischen zweier Klänge.

## Dateien
- `scripts/sound_synth.gd`: drei Funktionen anhängen, sonst nichts ändern
- `tests/test_sound_synth.gd`: Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
Am Ende von `scripts/sound_synth.gd` anhängen:
```gdscript


## Ton mit fester Frequenz. Mit `fade` wird er je 5 ms ein- und ausgeblendet (gegen Knacken).
static func tone(freq: float, duration: float, wave: int = Wave.SINE, volume: float = 0.5, fade: bool = true) -> PackedFloat32Array:
	var n := int(duration * MIX_RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var fade_len := int(0.005 * MIX_RATE)
	for i in n:
		var env := 1.0
		if fade and fade_len > 0:
			env = minf(1.0, minf(float(i) / fade_len, float(n - 1 - i) / fade_len))
		out[i] = wave_value(wave, freq * i / MIX_RATE) * volume * env
	return out


## Weißes Rauschen; derselbe `seed_value` ergibt immer dasselbe Rauschen.
static func noise(duration: float, volume: float = 0.5, seed_value: int = 1) -> PackedFloat32Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var n := int(duration * MIX_RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	for i in n:
		out[i] = rng.randf_range(-1.0, 1.0) * volume
	return out


## Addiert zwei Klänge. Das Ergebnis ist so lang wie der längere; fehlende Werte zählen als 0.
static func mix(a: PackedFloat32Array, b: PackedFloat32Array) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(maxi(a.size(), b.size()))
	for i in out.size():
		var va := a[i] if i < a.size() else 0.0
		var vb := b[i] if i < b.size() else 0.0
		out[i] = va + vb
	return out
```

## Tests
In `tests/test_sound_synth.gd` anhängen:
- `test_ton_laenge`: `SoundSynth.tone(441.0, 0.1).size()` ist 2205
- `test_ton_lautstaerke`: `var t := SoundSynth.tone(441.0, 0.1, SoundSynth.Wave.SQUARE, 0.3)`; der größte Betrag aller Werte (Schleife mit `m = maxf(m, absf(v))`) ist höchstens 0.3001 und mindestens 0.29; `t[0]` ist 0.0 (eingeblendet)
- `test_ton_ohne_blende`: `var t := SoundSynth.tone(441.0, 0.1, SoundSynth.Wave.SQUARE, 0.3, false)` → `absf(t[0] - 0.3) < 0.0001`
- `test_rauschen`: `var a := SoundSynth.noise(0.05, 0.5, 3)`, `var b := SoundSynth.noise(0.05, 0.5, 3)`, `var c := SoundSynth.noise(0.05, 0.5, 4)` → `a == b` ist wahr, `a == c` ist falsch, `a.size()` ist `int(0.05 * SoundSynth.MIX_RATE)`
- `test_mischen`: `var m := SoundSynth.mix(PackedFloat32Array([0.1, 0.2, 0.3]), PackedFloat32Array([0.5]))` → `m.size()` ist 3; `absf(m[0] - 0.6) < 0.0001`, `absf(m[2] - 0.3) < 0.0001`

Review (16.10.2026): gemergt.
