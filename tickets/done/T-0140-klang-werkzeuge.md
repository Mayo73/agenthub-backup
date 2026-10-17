---
id: T-0140
title: Klangwerkzeuge Gleitton, Ausblenden, Tiefpass (SoundSynth)
project: zellenphase
priority: 3
---
## Ziel
`SoundSynth` (aus Drift übernommen) bekommt drei Werkzeuge für die Klänge der Zellenphase: einen Gleitton, ein Ausblenden und einen einfachen Tiefpass für weiches Wasserrauschen.

## Dateien
- `scripts/sound_synth.gd`: drei Funktionen am Ende anhängen, sonst nichts ändern
- `tests/test_sound_synth_extra.gd`: neu (die vorhandene `tests/test_sound_synth.gd` nicht ändern)

## Akzeptanzkriterien
Am Ende von `scripts/sound_synth.gd` genau so anhängen:
```gdscript


## Ton, dessen Frequenz linear von f0 nach f1 gleitet. Die Phase wird aufsummiert, damit nichts knackt.
static func sweep(f0: float, f1: float, duration: float, wave: int = Wave.SINE, volume: float = 0.5) -> PackedFloat32Array:
	var n := int(duration * MIX_RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var phase := 0.0
	for i in n:
		var f := lerpf(f0, f1, float(i) / maxf(1.0, float(n - 1)))
		out[i] = wave_value(wave, phase) * volume
		phase += f / MIX_RATE
	return out


## Blendet linear auf 0 aus: erster Wert unverändert, letzter Wert 0.
static func fade_out(samples: PackedFloat32Array) -> PackedFloat32Array:
	var out := samples.duplicate()
	var n := out.size()
	for i in n:
		out[i] *= 1.0 - float(i) / maxf(1.0, float(n - 1))
	return out


## Einfacher Tiefpass (y += alpha * (x - y)); kleines alpha klingt dumpfer.
static func lowpass(samples: PackedFloat32Array, alpha: float) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(samples.size())
	var y := 0.0
	for i in samples.size():
		y += alpha * (samples[i] - y)
		out[i] = y
	return out
```

## Tests
`tests/test_sound_synth_extra.gd` mit `extends "res://tests/base_test.gd"`:
- `test_sweep_laenge`: `SoundSynth.sweep(100.0, 200.0, 0.5).size()` ist `int(0.5 * SoundSynth.MIX_RATE)`
- `test_sweep_start_und_lautstaerke`: `var s := SoundSynth.sweep(440.0, 880.0, 0.1, SoundSynth.Wave.SINE, 0.5)` → `s[0]` ist 0.0; in einer Schleife ist jeder Wert `absf(v) <= 0.5001`
- `test_sweep_frequenz`: `var s := SoundSynth.sweep(1000.0, 1000.0, 1.0, SoundSynth.Wave.SQUARE, 1.0)`; zähle in einer Schleife ab `i = 1` die Wechsel (`s[i] != s[i - 1]`) → `absi(wechsel - 2000) <= 4` wahr
- `test_ausblenden`: `var t := SoundSynth.tone(440.0, 0.1, SoundSynth.Wave.SQUARE, 0.5, false)`, `var f := SoundSynth.fade_out(t)` → `f.size()` gleich `t.size()`; `f[0]` ist 0.5; `f[f.size() - 1]` ist 0.0; `t[0]` ist weiterhin 0.5 (Eingabe unverändert)
- `test_tiefpass_konstant`: `var c := PackedFloat32Array()`, 100-mal `c.append(1.0)`; `var l := SoundSynth.lowpass(c, 0.5)` → `l[0]` ist 0.5; `l[1]` ist 0.75; `l[99] > 0.999` wahr
- `test_tiefpass_glaettet`: `var n := SoundSynth.noise(0.5, 0.5, 3)`, `var l := SoundSynth.lowpass(n, 0.05)`; die Summe der Beträge von `l` ist kleiner als die Hälfte der Summe der Beträge von `n`

Review (16.10.2026): gemergt.
