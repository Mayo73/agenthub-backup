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
