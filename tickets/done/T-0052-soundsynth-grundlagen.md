---
id: T-0052
title: Klangerzeugung – Grundlagen (SoundSynth)
project: drift
priority: 3
---
## Ziel
Drift soll Sound bekommen, aber ohne Audiodateien: Alle Klänge werden im Code erzeugt. Diese Klasse liefert die Grundbausteine: Wellenformen, Umwandlung in 16-Bit-PCM und daraus einen abspielbaren `AudioStreamWAV`.

## Dateien
- `scripts/sound_synth.gd`: neu, beginnt mit `class_name SoundSynth` und `extends RefCounted`
- `tests/test_sound_synth.gd`: neu

## Akzeptanzkriterien
Genau dieser Code in `scripts/sound_synth.gd`:
```gdscript
class_name SoundSynth
extends RefCounted
## Erzeugt Klänge im Code (keine Audiodateien nötig). Abtastwerte liegen zwischen -1 und 1.

const MIX_RATE := 22050

enum Wave { SINE, SQUARE, SAW }


## Wert der Wellenform bei Phase `t` (eine Schwingung = 1.0), Ergebnis -1 .. 1.
static func wave_value(wave: int, t: float) -> float:
	var p := fposmod(t, 1.0)
	match wave:
		Wave.SQUARE:
			return 1.0 if p < 0.5 else -1.0
		Wave.SAW:
			return 2.0 * p - 1.0
		_:
			return sin(p * TAU)


## Wandelt Abtastwerte in 16-Bit-PCM (little endian) um. Werte außerhalb -1 .. 1 werden begrenzt.
static func to_pcm16(samples: PackedFloat32Array) -> PackedByteArray:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		bytes.encode_s16(i * 2, int(round(clampf(samples[i], -1.0, 1.0) * 32767.0)))
	return bytes


## Macht aus Abtastwerten einen abspielbaren Stream (mono, MIX_RATE), auf Wunsch als Schleife.
static func make_stream(samples: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = to_pcm16(samples)
	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = samples.size()
	return stream
```

## Tests
Neue Datei `tests/test_sound_synth.gd` mit `extends "res://tests/base_test.gd"`:
- `test_sinus`: `absf(SoundSynth.wave_value(SoundSynth.Wave.SINE, 0.25) - 1.0) < 0.001`; `absf(SoundSynth.wave_value(SoundSynth.Wave.SINE, 0.0)) < 0.001`
- `test_rechteck`: `wave_value(Wave.SQUARE, 0.25)` ist 1.0, `wave_value(Wave.SQUARE, 0.75)` ist -1.0, `wave_value(Wave.SQUARE, 1.25)` ist 1.0
- `test_saegezahn`: `wave_value(Wave.SAW, 0.0)` ist -1.0, `wave_value(Wave.SAW, 0.5)` ist 0.0
- `test_pcm16`: `var b := SoundSynth.to_pcm16(PackedFloat32Array([1.0, -1.0, 0.0, 2.0]))` → `b.size()` ist 8, `b.decode_s16(0)` ist 32767, `b.decode_s16(2)` ist -32767, `b.decode_s16(4)` ist 0, `b.decode_s16(6)` ist 32767
- `test_stream_ohne_schleife`: `var s := SoundSynth.make_stream(PackedFloat32Array([0.0, 0.5, -0.5]), false)` → `s.data.size()` ist 6, `s.mix_rate` ist 22050, `s.format` ist `AudioStreamWAV.FORMAT_16_BITS`, `s.loop_mode` ist `AudioStreamWAV.LOOP_DISABLED`
- `test_stream_mit_schleife`: `var samples := PackedFloat32Array()`, `samples.resize(100)`, `var s := SoundSynth.make_stream(samples, true)` → `s.loop_mode` ist `AudioStreamWAV.LOOP_FORWARD`, `s.loop_end` ist 100

Review (16.10.2026): gemergt.
